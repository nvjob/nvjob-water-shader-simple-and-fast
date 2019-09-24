// Copyright (c) 2016 Unity Technologies. MIT license - license_unity.txt
// #NVJOB Dynamic Sky Lite (Standard render) V2.2. MIT license - license_nvjob.txt
// #NVJOB Nicholas Veselov - https://nvjob.pro, http://nvjob.dx.am


using UnityEngine;


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



public class DynamicSkyLite : MonoBehaviour
{
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    public float ssgUvRotateSpeed = 1;
    public float ssgUvRotateDistance = 1;
    public Transform player;


    //---------------------------------

    Vector2 ssgVector;
    Transform tr;


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    


    private void Awake()
    {
        //---------------------------------

        ssgVector = Vector2.zero;
        tr = transform;

        //---------------------------------
    }



    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    


    void Update()
    {
        //---------------------------------

        ssgVector = Quaternion.AngleAxis(Time.time * ssgUvRotateSpeed, Vector3.forward) * Vector2.one * ssgUvRotateDistance;
        Shader.SetGlobalFloat("_SkyShaderUvX", ssgVector.x);
        Shader.SetGlobalFloat("_SkyShaderUvZ", ssgVector.y);

        //---------------------------------

        tr.position = new Vector3(player.position.x, tr.position.y, player.position.z);

        //---------------------------------
    }



    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}
