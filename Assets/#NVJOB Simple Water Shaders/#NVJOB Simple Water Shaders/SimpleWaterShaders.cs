// Copyright (c) 2016 Unity Technologies. MIT license - license_unity.txt
// #NVJOB Simple Water Shaders. MIT license - license_nvjob.txt
// #NVJOB Simple Water Shaders v1.5 - https://nvjob.github.io/unity/nvjob-water-shader
// #NVJOB Nicholas Veselov - https://nvjob.github.io


using UnityEngine;

[HelpURL("https://nvjob.github.io/unity/nvjob-water-shader")]
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
    public Transform windZone;

    //--------------

    Vector2 lwVector, lwNVector;
    

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    private void Awake()
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

        lwVector = Quaternion.AngleAxis(Time.time * UvRotateSpeed, Vector3.forward) * Vector2.one * UvRotateDistance;
        lwNVector = Quaternion.AngleAxis(Time.time * UvBumpRotateSpeed, Vector3.forward) * Vector2.one * UvBumpRotateDistance;

        //--------------

        Shader.SetGlobalFloat("_WaterLocalUvX", lwVector.x);
        Shader.SetGlobalFloat("_WaterLocalUvZ", lwVector.y);
        Shader.SetGlobalFloat("_WaterLocalUvNX", lwNVector.x);
        Shader.SetGlobalFloat("_WaterLocalUvNZ", lwNVector.y);

        //--------------

        if (windZone != null) windZone.rotation = Quaternion.LookRotation(new Vector3(lwNVector.x, 0, lwNVector.y), Vector3.zero);

        //--------------
    }


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}
