// #NVJOB Dynamic Sky (for Demo)
// Full Asset #NVJOB Dynamic Sky - https://nvjob.github.io/unity/nvjob-dynamic-sky-lite
// #NVJOB Nicholas Veselov - https://nvjob.github.io


using UnityEngine;

[HelpURL("https://nvjob.github.io/unity/nvjob-dynamic-sky-lite")]
[AddComponentMenu("#NVJOB/Dynamic Sky (for Demo)")]


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


[ExecuteInEditMode]
public class DynamicSkyForDemo : MonoBehaviour
{
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    public float ssgUvRotateSpeed = 1;
    public float ssgUvRotateDistance = 1;
    public Transform player;

    //--------------

    Vector2 ssgVector;
    Transform tr;


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    private void Awake()
    {
        //--------------

        ssgVector = Vector2.zero;
        tr = transform;

        //--------------
    }


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    void Update()
    {
        //--------------

        ssgVector = Quaternion.AngleAxis(Time.time * ssgUvRotateSpeed, Vector3.forward) * Vector2.one * ssgUvRotateDistance;
        Shader.SetGlobalFloat("_SkyShaderUvX", ssgVector.x);
        Shader.SetGlobalFloat("_SkyShaderUvZ", ssgVector.y);

        //--------------

        if (player != null) tr.position = new Vector3(player.position.x, tr.position.y, player.position.z);

        //--------------
    }


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}
