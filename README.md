# #NVJOB Water Shader - simple and fast. v1.4.5

![GitHub Logo](https://raw.githubusercontent.com/nvjob/nvjob.github.io/master/repo/unity%20assets/water%20shader%20saf%20sr/144/pic/1.jpg)

Simple and fast water shader. This shader is suitable for scenes where water is not a key element of the scene, but a decorative element. Supported rendering path deferred and forward. It works on all platforms.

Unity Asset Store - https://assetstore.unity.com/packages/vfx/shaders/nvjob-water-shader-simple-and-fast-149916 <br/>
Previous Versions - https://github.com/nvjob/NVJOB-Water-Shader-old-versions

https://www.youtube.com/watch?v=94dRrLFMA1k <br>
https://www.youtube.com/watch?v=q91znPUJtPY

![GitHub Logo](https://raw.githubusercontent.com/nvjob/nvjob.github.io/master/repo/unity%20assets/water%20shader%20saf%20sr/144/pic/5.jpg)

------------------------------------

![GitHub Logo](https://raw.githubusercontent.com/nvjob/nvjob.github.io/master/repo/unity%20assets/water%20shader%20saf%20sr/144/pic/1.gif)

### Prerequisites

To work on the project, you will need a Unity version of at least 2019.1.8 (64-bit).

### Information

The movement of the waves is carried out using global shader variables: _WaterLocalUvX, _WaterLocalUvZ, _WaterLocalUvNX, _WaterLocalUvNZ.

_WaterLocalUvX, _WaterLocalUvZ - Offset main texture.<br/>
_WaterLocalUvNX, _WaterLocalUvNZ - Offset normal map texture.

#### An example of a script for the movement of water.

```
using UnityEngine;

public class Water : MonoBehaviour
{
    public float UvRotateSpeed = 0.4f;
    public float UvRotateDistance = 2.0f;
    public float UvBumpRotateSpeed = 0.4f;
    public float UvBumpRotateDistance = 2.0f;

    Vector2 lwVector, lwNVector;

    private void Awake()
    {
        lwVector = Vector2.zero;
        lwNVector = Vector2.zero;
    }

    void Update()
    {
        lwVector = Quaternion.AngleAxis(Time.time * UvRotateSpeed, Vector3.forward) * Vector2.one * UvRotateDistance;
        lwNVector = Quaternion.AngleAxis(Time.time * UvBumpRotateSpeed, Vector3.forward) * Vector2.one * UvBumpRotateDistance;
        Shader.SetGlobalFloat("_WaterLocalUvX", lwVector.x);
        Shader.SetGlobalFloat("_WaterLocalUvZ", lwVector.y);
        Shader.SetGlobalFloat("_WaterLocalUvNX", lwNVector.x);
        Shader.SetGlobalFloat("_WaterLocalUvNZ", lwNVector.y);
    }
}
```

#### For working shaders on mobile platforms with Forward Rendering.
In asset this fix is already added to the general script.

```
using UnityEngine;

[ExecuteInEditMode]
public class depthTextureFix : MonoBehaviour
{
    void OnEnable()
    {
        GetComponent<Camera>().depthTextureMode = DepthTextureMode.Depth;
    }
}
```

#### The rotation of the wind synchronously with water (optionally).
```
using UnityEngine;

public class WindZoneRot : MonoBehaviour
{
    Transform tr;

    private void Awake()
    {
        tr = transform;
    }

    void LateUpdate()
    {
        tr.rotation = Quaternion.LookRotation(new Vector3(Shader.GetGlobalFloat("_WaterLocalUvNX"), 0, Shader.GetGlobalFloat("_WaterLocalUvNZ")), Vector3.zero) * Quaternion.Euler(0, -40, 0);
    }
}
```

![GitHub Logo](https://raw.githubusercontent.com/nvjob/nvjob.github.io/master/repo/unity%20assets/water%20shader%20saf%20sr/144/pic/2.jpg)
![GitHub Logo](https://raw.githubusercontent.com/nvjob/nvjob.github.io/master/repo/unity%20assets/water%20shader%20saf%20sr/144/pic/3.jpg)
![GitHub Logo](https://raw.githubusercontent.com/nvjob/nvjob.github.io/master/repo/unity%20assets/water%20shader%20saf%20sr/144/pic/4.jpg)

-------------------------------------------------------------------

### Authors
Designed by #NVJOB Nicholas Veselov - https://nvjob.github.io

### License
MIT License - https://nvjob.github.io/mit-license

### Donate
Help for this project - https://nvjob.github.io/donate

### Report a Problem
Report a Problem / Issue Tracker / FAQ - https://nvjob.github.io/reportaproblem
