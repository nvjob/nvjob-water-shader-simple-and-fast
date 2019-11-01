// Copyright (c) 2016 Unity Technologies. MIT license - license_unity.txt
// #NVJOB Water Shader - simple and fast. MIT license - license_nvjob.txt
// #NVJOB Water Shader - simple and fast V1.4.5 - https://nvjob.github.io/unity/nvjob-water-shader
// #NVJOB Nicholas Veselov (independent developer) - https://nvjob.github.io


using UnityEngine;


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


[ExecuteInEditMode] // For DepthTextureMode


public class Water : MonoBehaviour
{
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
       

    public float UvRotateSpeed = 0.4f;
    public float UvRotateDistance = 2.0f;
    public float UvBumpRotateSpeed = 0.4f;
    public float UvBumpRotateDistance = 2.0f;
    public bool depthTextureModeOn = true;

    //---------------------------------

    Vector2 lwVector, lwNVector;
    

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    private void Awake()
    {
        //---------------------------------

        lwVector = Vector2.zero;
        lwNVector = Vector2.zero;

        //---------------------------------
    }


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    void OnEnable()
    {
        //---------------------------------

        if (depthTextureModeOn) Camera.main.depthTextureMode = DepthTextureMode.Depth;

        //---------------------------------
    }


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    void Update()
    {
        //---------------------------------

        lwVector = Quaternion.AngleAxis(Time.time * UvRotateSpeed, Vector3.forward) * Vector2.one * UvRotateDistance;
        lwNVector = Quaternion.AngleAxis(Time.time * UvBumpRotateSpeed, Vector3.forward) * Vector2.one * UvBumpRotateDistance;

        //---------------------------------

        Shader.SetGlobalFloat("_WaterLocalUvX", lwVector.x);
        Shader.SetGlobalFloat("_WaterLocalUvZ", lwVector.y);
        Shader.SetGlobalFloat("_WaterLocalUvNX", lwNVector.x);
        Shader.SetGlobalFloat("_WaterLocalUvNZ", lwNVector.y);

        //---------------------------------
    }


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}
