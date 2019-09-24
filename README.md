# #NVJOB Water Shader - simple and fast. v1.4.4

![GitHub Logo](https://raw.githubusercontent.com/nvjob/NVJOB-Water-Shader-simple-and-fast/master/Images/water%200.png)

![GitHub Logo](https://raw.githubusercontent.com/nvjob/NVJOB-Water-Shader-simple-and-fast/master/Images/water%201.png)

Simple and fast water shader. This shader is suitable for scenes where water is not a key element of the scene, but a decorative element. Supported rendering path deferred and forward.

Unity Asset Store - https://assetstore.unity.com/packages/vfx/shaders/nvjob-water-shader-simple-and-fast-149916

Previous Versions - https://github.com/nvjob/NVJOB-Water-Shader-old-versions

https://www.youtube.com/watch?v=94dRrLFMA1k<br>
https://www.youtube.com/watch?v=q91znPUJtPY

![GitHub Logo](https://raw.githubusercontent.com/nvjob/NVJOB-Water-Shader-simple-and-fast/master/Images/water%202.png)

------------------------------------

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
<br/>

![GitHub Logo](https://raw.githubusercontent.com/nvjob/NVJOB-Water-Shader-simple-and-fast/master/Images/water%204.png)

------------------------------------

### Authors
Designed by #NVJOB Nicholas Veselov | https://nvjob.pro | http://nvjob.dx.am | https://twitter.com/nvjob

### License
This project is licensed under the MIT License - see the LICENSE file for details

### Donate
You can thank me by a voluntary donation. https://nvjob.pro/donations.html
