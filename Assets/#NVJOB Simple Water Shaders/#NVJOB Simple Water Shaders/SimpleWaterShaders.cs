// Copyright (c) 2016 Unity Technologies. MIT license - license_unity.txt
// #NVJOB Simple Water Shaders. MIT license - license_nvjob.txt
// #NVJOB Simple Water Shaders v1.6 - https://nvjob.github.io/unity/nvjob-simple-water-shaders
// #NVJOB Nicholas Veselov - https://nvjob.github.io


using UnityEngine;
using System.Collections;

[HelpURL("https://nvjob.github.io/unity/nvjob-simple-water-shaders")]
[AddComponentMenu("#NVJOB/Simple Water Shaders")]


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


[ExecuteInEditMode]
public class SimpleWaterShaders : MonoBehaviour
{
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
       

    public float UvRotateSpeed = 0.4f;
    public float UvRotateDistance = 2.0f;
    public float UvBumpRotateSpeed = 0.4f;
    public float UvBumpRotateDistance = 2.0f;
    public bool depthTextureModeOn = true;
    public bool waterSyncWind;
    public Transform windZone;
    public bool mirrorOn = false;
    public bool disablePixelLights = false;
    public bool mirrorBackSide = false;
    public int textureSize = 1024;
    public float clipPlaneOffset = -0.5f;

    //--------------

    Vector2 lwVector, lwNVector;

    LayerMask m_ReflectLayers = -1;
    Hashtable m_ReflectionCameras = new Hashtable();
    RenderTexture m_ReflectionTexture = null;
    int m_OldReflectionTextureSize = 0;
    static bool s_InsideRendering = false;


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    void Awake()
    {
        //--------------

        lwVector = Vector2.zero;
        lwNVector = Vector2.zero;

        //--------------
    }


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    void OnEnable()
    {
        //--------------

        if (depthTextureModeOn) Camera.main.depthTextureMode = DepthTextureMode.Depth;

        //--------------
    }


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    void Update()
    {
        //--------------

        if (waterSyncWind == false)
        {
            lwVector = Quaternion.AngleAxis(Time.time * UvRotateSpeed, Vector3.forward) * Vector2.one * UvRotateDistance;
            lwNVector = Quaternion.AngleAxis(Time.time * UvBumpRotateSpeed, Vector3.forward) * Vector2.one * UvBumpRotateDistance;
            if (windZone != null) windZone.rotation = Quaternion.LookRotation(new Vector3(lwNVector.x, 0, lwNVector.y), Vector3.zero) * Quaternion.Euler(0, -90, 0);
        }
        else
        {
            if (windZone != null)
            {
                Quaternion windQ = new Quaternion(windZone.rotation.x, windZone.rotation.z, windZone.rotation.y, -windZone.rotation.w);
                Vector3 windV = windQ * Vector3.up * 0.2f;
                lwVector = windV * Time.time * UvRotateSpeed;
                lwNVector = windV * Time.time * UvBumpRotateSpeed;
            }
        }

        //--------------

        Shader.SetGlobalFloat("_WaterLocalUvX", lwVector.x);
        Shader.SetGlobalFloat("_WaterLocalUvZ", lwVector.y);
        Shader.SetGlobalFloat("_WaterLocalUvNX", lwNVector.x);
        Shader.SetGlobalFloat("_WaterLocalUvNZ", lwNVector.y);

        //--------------
    }



    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
       


    void OnWillRenderObject()
    {
        //--------------

        if (mirrorOn == true)
        {
            if (!enabled || !GetComponent<Renderer>() || !GetComponent<Renderer>().sharedMaterial || !GetComponent<Renderer>().enabled) return;
            Camera cam = Camera.current;
            if (!cam) return;
            if (s_InsideRendering) return;
            s_InsideRendering = true;
            Camera reflectionCamera;
            CreateMirrorObjects(cam, out reflectionCamera);
            reflectionCamera.renderingPath = RenderingPath.Forward;
            Vector3 pos = transform.position;
            Vector3 normal = transform.up;
            if (mirrorBackSide == true) normal = -normal;
            int oldPixelLightCount = QualitySettings.pixelLightCount;
            if (disablePixelLights == true) QualitySettings.pixelLightCount = 0;
            UpdateCameraModes(cam, reflectionCamera);
            float d = -Vector3.Dot(normal, pos) - clipPlaneOffset;
            Vector4 reflectionPlane = new Vector4(normal.x, normal.y, normal.z, d);
            Matrix4x4 reflection = Matrix4x4.zero;
            CalculateReflectionMatrix(ref reflection, reflectionPlane);
            Vector3 oldpos = cam.transform.position;
            Vector3 newpos = reflection.MultiplyPoint(oldpos);
            reflectionCamera.worldToCameraMatrix = cam.worldToCameraMatrix * reflection;
            Vector4 clipPlane = CameraSpacePlane(reflectionCamera, pos, normal, 1.0f);
            Matrix4x4 projection = cam.projectionMatrix;
            CalculateObliqueMatrix(ref projection, clipPlane);
            reflectionCamera.projectionMatrix = projection;
            reflectionCamera.cullingMask = ~(1 << 4) & m_ReflectLayers.value;
            reflectionCamera.targetTexture = m_ReflectionTexture;
            GL.invertCulling = true;
            reflectionCamera.transform.position = newpos;
            Vector3 euler = cam.transform.eulerAngles;
            reflectionCamera.transform.eulerAngles = new Vector3(0, euler.y, euler.z);
            reflectionCamera.Render();
            reflectionCamera.transform.position = oldpos;
            GL.invertCulling = false;
            Material[] materials = GetComponent<Renderer>().sharedMaterials;
            foreach (Material mat in materials) if (mat.HasProperty("_MirrorReflectionTex")) mat.SetTexture("_MirrorReflectionTex", m_ReflectionTexture);
            Matrix4x4 scaleOffset = Matrix4x4.TRS(new Vector3(0.5f, 0.5f, 0.5f), Quaternion.identity, new Vector3(0.5f, 0.5f, 0.5f));
            Vector3 scale = transform.lossyScale;
            Matrix4x4 mtx = transform.localToWorldMatrix * Matrix4x4.Scale(new Vector3(1.0f / scale.x, 1.0f / scale.y, 1.0f / scale.z));
            mtx = scaleOffset * cam.projectionMatrix * cam.worldToCameraMatrix * mtx;
            foreach (Material mat in materials) mat.SetMatrix("_ProjMatrix", mtx);
            if (disablePixelLights == true) QualitySettings.pixelLightCount = oldPixelLightCount;
            s_InsideRendering = false;
        }

        //--------------
    }


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    void OnDisable()
    {
        //--------------

        if (mirrorOn == true)
        {
            if (m_ReflectionTexture)
            {
                DestroyImmediate(m_ReflectionTexture);
                m_ReflectionTexture = null;
            }
            foreach (DictionaryEntry kvp in m_ReflectionCameras) DestroyImmediate(((Camera)kvp.Value).gameObject);
            m_ReflectionCameras.Clear();
        }

        //--------------
    }


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    void UpdateCameraModes(Camera src, Camera dest)
    {
        //--------------

        if (dest == null) return;

        dest.clearFlags = src.clearFlags;
        dest.backgroundColor = src.backgroundColor;

        //--------------

        if (src.clearFlags == CameraClearFlags.Skybox)
        {
            Skybox sky = src.GetComponent(typeof(Skybox)) as Skybox;
            Skybox mysky = dest.GetComponent(typeof(Skybox)) as Skybox;
            if (!sky || !sky.material)
            {
                mysky.enabled = false;
            }
            else
            {
                mysky.enabled = true;
                mysky.material = sky.material;
            }
        }

        //--------------

        dest.farClipPlane = src.farClipPlane;
        dest.nearClipPlane = src.nearClipPlane;
        dest.orthographic = src.orthographic;
        dest.fieldOfView = src.fieldOfView;
        dest.aspect = src.aspect;
        dest.orthographicSize = src.orthographicSize;

        //--------------
    }


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    void CreateMirrorObjects(Camera currentCamera, out Camera reflectionCamera)
    {
        //--------------

        reflectionCamera = null;

        if (!m_ReflectionTexture || m_OldReflectionTextureSize != textureSize)
        {
            if (m_ReflectionTexture) DestroyImmediate(m_ReflectionTexture);
            m_ReflectionTexture = new RenderTexture(textureSize, textureSize, 16);
            m_ReflectionTexture.name = "__MirrorReflection" + GetInstanceID();
            m_ReflectionTexture.isPowerOfTwo = true;
            m_ReflectionTexture.hideFlags = HideFlags.DontSave;
            m_OldReflectionTextureSize = textureSize;
        }

        reflectionCamera = m_ReflectionCameras[currentCamera] as Camera;

        if (!reflectionCamera)
        {
            GameObject go = new GameObject("Mirror Refl Camera id" + GetInstanceID() + " for " + currentCamera.GetInstanceID(), typeof(Camera), typeof(Skybox));
            reflectionCamera = go.GetComponent<Camera>();
            reflectionCamera.enabled = false;
            reflectionCamera.transform.position = transform.position;
            reflectionCamera.transform.rotation = transform.rotation;
            reflectionCamera.gameObject.AddComponent<FlareLayer>();
            go.hideFlags = HideFlags.HideAndDontSave;
            m_ReflectionCameras[currentCamera] = reflectionCamera;
        }

        //--------------
    }


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    Vector4 CameraSpacePlane(Camera cam, Vector3 pos, Vector3 normal, float sideSign)
    {
        //--------------

        Vector3 offsetPos = pos + normal * clipPlaneOffset;
        Matrix4x4 m = cam.worldToCameraMatrix;
        Vector3 cpos = m.MultiplyPoint(offsetPos);
        Vector3 cnormal = m.MultiplyVector(normal).normalized * sideSign;
        return new Vector4(cnormal.x, cnormal.y, cnormal.z, -Vector3.Dot(cpos, cnormal));

        //--------------
    }


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    static void CalculateObliqueMatrix(ref Matrix4x4 projection, Vector4 clipPlane)
    {
        //--------------

        Vector4 q = projection.inverse * new Vector4(
            Sgn(clipPlane.x),
            Sgn(clipPlane.y),
            1.0f,
            1.0f
        );

        Vector4 c = clipPlane * (2.0F / (Vector4.Dot(clipPlane, q)));
        projection[2] = c.x - projection[3];
        projection[6] = c.y - projection[7];
        projection[10] = c.z - projection[11];
        projection[14] = c.w - projection[15];

        //--------------
    }


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    static float Sgn(float a)
    {
        //--------------

        if (a > 0.0f) return 1.0f;
        if (a < 0.0f) return -1.0f;
        return 0.0f;

        //--------------
    }


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
       

    static void CalculateReflectionMatrix(ref Matrix4x4 reflectionMat, Vector4 plane)
    {
        //--------------

        reflectionMat.m00 = 1F - 2F * plane[0] * plane[0];
        reflectionMat.m01 = -2F * plane[0] * plane[1];
        reflectionMat.m02 = -2F * plane[0] * plane[2];
        reflectionMat.m03 = -2F * plane[3] * plane[0];
        reflectionMat.m10 = -2F * plane[1] * plane[0];
        reflectionMat.m11 = 1F - 2F * plane[1] * plane[1];
        reflectionMat.m12 = -2F * plane[1] * plane[2];
        reflectionMat.m13 = -2F * plane[3] * plane[1];
        reflectionMat.m20 = -2F * plane[2] * plane[0];
        reflectionMat.m21 = -2F * plane[2] * plane[1];
        reflectionMat.m22 = 1F - 2F * plane[2] * plane[2];
        reflectionMat.m23 = -2F * plane[3] * plane[2];
        reflectionMat.m30 = 0F;
        reflectionMat.m31 = 0F;
        reflectionMat.m32 = 0F;
        reflectionMat.m33 = 1F;

        //--------------
    }


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}
