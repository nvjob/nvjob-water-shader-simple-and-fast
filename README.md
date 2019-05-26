# NVJOB Water Shader - simple and fast.

Version 1.4.2

Simple and fast water shader. This shader is suitable for scenes where water is not a key element of the scene, but a decorative element. Supported rendering path deferred and forward.

https://www.youtube.com/watch?v=q91znPUJtPY

![GitHub Logo](https://lh3.googleusercontent.com/LVsJ_COnZglvdbzRSil_vC8PL6qSC1qxbkfljpuZCsGgfN1JP8qW1UoD1yRev2HY-N-yb2NN-kFfF3CRO7EE1suIzBfa4Df4CR8Y-5gpmioxL_GytrxX9Lr_7p1cMEAc_NdLCpNPW8jFtlkSQ4RTn87XlGGO0WEQwObiGB04k2FimouAEKDCpHk3fDlNehNTYih4mvwQrts9G6AtXyVEolW8yVDykCU72YQRN_mkmngkb6blr9Yo1frOvpei6FakYAKFlwHq3p3UKb8aiSpoL6BRfyMXCE3hUZHzDReTj4hg3bu1a2b4U91pGBWNgecH4GxQDDaKQgNEct0nSuqKGCU7lcjbugZB_60MIdKhPzBfEIUjg1AsNsd3Z3R18_kp6mC996dIvC7tGg-nbUm1W6VSiQ1goki5KrZfARPbqlqv9XPrKJdVFj-C_bZt9HkMKE0OVOTvsanI4IZ-e9TVRPZ9NAnXpSjEmFliNlaNimJqTp8zX7-W_81cAKfBTdRDIgZUyt453gZGfZGXYfqIcsnYatHd5O_FC5XtO1N38sj_blXpet0GwUtOvN8RGBUBvwHTkLtdyvvrV5CfcmAzGYqdNbwUuJAL23xFRf_Agllh2YVICyVgyQNp-xI1LO3T3xL5Tk6wKAYFB_7M0o5JtcgujpIe2GJMDoJxhjjSRv3ODJeNQ_CrDDQJHIJJk5f6VIesCi52FLp1AgLTB0FJbssk=w1632-h911-no)

------------------------------------

### Prerequisites

To work on the project, you will need a Unity version of at least 2019.1.0f2 (64-bit).

### Information

The movement of the waves is carried out using global shader variables: _WaterLocalUvX, _WaterLocalUvZ, _WaterLocalUvNX, _WaterLocalUvNZ.

_WaterLocalUvX, _WaterLocalUvZ - Offset main texture.<br/>
_WaterLocalUvNX, _WaterLocalUvNZ - Offset normal map texture.

#### An example of a script for the movement of water.

```
using UnityEngine;

public class Water : MonoBehaviour
{
    public float UvRotateSpeed = 0.2;
    public float UvRotateDistance = 1;
    public float UvBumpRotateSpeed = 0.4;
    public float UvBumpRotateDistance = 2;

    float timeTime;
    Vector2 Vector2one, lwVector, lwNVector;
    Vector3 Vector3forward;    

    private void Awake()
    {
        lwVector = Vector2.zero;
        lwNVector = Vector2.zero;
    }

    void Update()
    {
        if (timeTime != Time.time) timeTime = Time.time;
        if (Vector3forward != Vector3.forward) Vector3forward = Vector3.forward;
        if (Vector2one != Vector2.one) Vector2one = Vector2.one;

        lwVector = Quaternion.AngleAxis(timeTime * UvRotateSpeed, Vector3forward) * Vector2one * UvRotateDistance;
        lwNVector = Quaternion.AngleAxis(timeTime * UvBumpRotateSpeed, Vector3forward) * Vector2one * UvBumpRotateDistance;

        Shader.SetGlobalFloat("_WaterLocalUvX", lwVector.x);
        Shader.SetGlobalFloat("_WaterLocalUvZ", lwVector.y);
        Shader.SetGlobalFloat("_WaterLocalUvNX", lwNVector.x);
        Shader.SetGlobalFloat("_WaterLocalUvNZ", lwNVector.y);
    }
}
```
<br/>

![GitHub Logo](https://lh3.googleusercontent.com/zpGEbAfdPEVf2EJH4om8x7kGZik0Wl8xOl3SKyhm7bBmcT2S0SdUtiPlV-mBkHs7JXNI2Lu2JqUGx7-_G_eU4Qza4z2uWLYtH7PBH8JXzb4TLWZMqsSmRexXFqaeQJoJYL8Bp8StncFEDV8f6kjHz4zDtILshcVgWpwhWN8Z6I-nUq1Csu6FSmB-lnFCFLhDwglf_NZmQf9RQYSFjNWDBbiAqOT6c3rNAySAmHiGf5xija_0Rf0sVZu81wv64ZOP3Bmsh_e78l3i-lwhwj43G0F9fE6ZYETv_QkmpIHfMTBwKl7dNgXXOG8MOpJ-ua18VxDHp4-zp1qI0CLk5xsRvINxam3ROGUEARFvBh9Qm3nDOeNRE-U_ogePPEcpiZ0HXF-qS9-N4oDqUVp7wjCazbTdaYzDsBjSjyzXZdtl9A0BicG5JrI3HTpjuxkRLrjaQytmfUBcK1N9xTWSJcpS0WUoLo9R4ufOFMub6hsw-H1pfc3qL5vxP4FLDKFQ2eujsnSYKackT78w16uUpTdZhpPHFdZGDrXM8rizcrW0khThGC-OhN0yk0CjyvUShWRN9ikFZE1Mmv9UE8Oz7lBgf-gCZUL3OuUeCCEYSRkIgDaYxSwfTsGgtvGUrUCljRxMEIOBaPaNYjPCWKRgbWFOGt19I-5uItl1v3zfdLVu8ZIHYXhIf3ZNjUMPLMYnj_nB7ve7l1Q88Z9AgTvXAPNiLiEv=w383-h859-no)

------------------------------------

### Authors
Designed by #NVJOB Nicholas Veselov | https://nvjob.pro | http://nvjob.dx.am | https://twitter.com/nvjob

### License
This project is licensed under the MIT License - see the LICENSE file for details
