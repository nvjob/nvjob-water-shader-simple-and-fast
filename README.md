# NVJOB Water Shader - simple and fast.

Version 1.4.2

Simple and fast water shader. This shader is suitable for scenes where water is not a key element of the scene, but a decorative element. Supported rendering path deferred and forward.

https://www.youtube.com/watch?v=94dRrLFMA1k<br>
https://www.youtube.com/watch?v=q91znPUJtPY

![GitHub Logo](https://lh3.googleusercontent.com/NFyzCzkGzDacddxrSqlJNLGZFR4QRqE4XM6hReYXr9I2nbq72CnIazsfONuReDQgmXfurAjmnP1LVMBfsJtqbFwv34S_crCTg0kKa8a8h7M8ZAcE4AxU28mqSZvGYaeC8LYfcOBPOSlO6Tkv6F1x4T6nY3ocfH8gfLpO2UNCkoHy5VEZJoM9nwQdUe1axWH10HuOPLM_DwtihSKjg0k8k9n8By4E1_tAfvYsvxrdDhRWuRpGqRozu5ltm4juaaO3BHhKK0EpKyaS8qJ04XPrzFo4UNWAc6ukln7oHd8_LlIaUcNLOF-f1OSfLpVLW7Cyt_8ek1BtJLo2Zg1j5obiQ_NTyQ1WSkEPmPgbPiHsUzTMOEvze1Jzs56bS6CiukDfMShgIZ4pugQYdwW8FcVE7SvxsFwOvAtBtAEE2LrNbF6z5ySZawlFggklUBdgHTZRTXjBXsPxrBTSQDB6kDudqtlD1oZKWRJPGgv9wXa66pxkSpIYAJCKzT-Flv20Rckkn5Cs2FClLrwy7VUvNLwyJRw_W9zJOBmAsQWz_1eVrZo4hxZcgX3Z_cZWeSkuqTQinGm-nn3cq3pVQKPq-Md7a-L3QQb5McvfeB35Kf-4XpAP3ObuWyGnlrjvnW4pH8wDhfGxa5bC2Y8b5uulV1e1AS7XRdslZ0PG6wRc6zEY2fJ9CR6BPWURQNXsMqqEU5QN5oUn9sIquUz3NQ_VXjS1Z_kc=w1741-h979-no)

![GitHub Logo](https://lh3.googleusercontent.com/iTtXvj_LUt-7b0QcRr1Kx3R-JQaabYZliZMb5pVHAI_0TPwtN4CRpHdJwOY283bNGQzJbZN5YS4ZYCbxZwXBapBBj6f9Ghc_bXJh_prZMWd_9OkQJqFLIvUuZv6yEIKn1pNA1aCs7Himyg6IabUSqUq6qI9tVWe3qXr8vnnC12xURcy0X0onGTUH_m9gAem6YIrmnkxB82ZWYAUFCDyYQWNi9_dOrU0Cx3ma5fgaCHo82e6NOhWdUjl1ac6tSb-AhNmTc-NciTDRfDGU9cRDapr_eMecNs70Ac7Qgn8AkM4cs0xhzavuV44xJuH533ng8NZg5IMr-yTnbdn62OZOwICLRBzeob1AnYDOjl7z9hJdh9EWXiHhGyr-zxoo0Jw9_F78SkI0-YsMSE-QvmZzs53NaMe38wV9KxmHqnoY-p6OFtWlDhURQsGJTJ7rMWVA5L0szKiBtO8NZJWFBo2EVK7fIqygkbpEBwn_PFxO09RmVR7B4R6N78h1dfKk86CBX3AMBSwhXUa7RZdIG-hXFvGc6WDGqwHuuobk7Xe1mYIKZJs9N_k3pBGCFIozQW1tB1bk_952miQV2Xrz2cXqOIRGIRmLKR4FrkiDF5oLriqNF7olL5j9LyLHRs3Sm7sUl69CX6iwVeJk0xNgeRYQ_NwEDHm9tI98Yw_kg9WitQ-ilF_0ddLW2Av51CYQDgrSkRazcLJ0BXgBdYW6ZZqA2WS5=w1741-h979-no)

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

![GitHub Logo](https://lh3.googleusercontent.com/TBrNEaB14NsmQxY0w8OAqeuqUpkYUdgoN-BWirZvgvAd11YF7YBN19OAnFO618yYAvFV9iZ9qMsSmydVISsgO9EPY8aoVvDNUvWx7G2woLsDfeN0yPJ1JOrGpLFHc87jypSGHk2eZ24JfNTJCcyxl5-wMkPEemjkZXEjQKgvrLYl-L_i6DLQHCEVFkqjbGZrB_4jspC1TductR66im2YQpw45kn1uXyNQ0Se9VtkxUXDlqaX8t44MfSCX2alQ6LO_gmZy8zrI_DCxoTGTzv9_Lf1J8aGfMgomc-2fh88NNPTyGI3hbzylVaj4N9CcEI-s7FX_YnhLIgqWK7ZICSg2g08NtjoCUmAuFibW4E7CHzyVt2tUKg4FkAEH_XeHzOg2QtYeeaYb9OBk7XtD_pwMo1dgEPFz-in2oJ-wJpWh_iGZRC5uFypUNtdiXxjNfeiibFltj-KyCc9i_N74siqW5XDu2ReuQ9KIF7BOpXAdV9q85aclx_jKU-b92Qcjlf7u_PGA1bY6c8xKJgcXtRSbJQGnP7IJ61aM7j9Fk7n3IMTFaulcMMDkvs-eaHig9ixI6K8k6uFyJiXB2jp_9C4MyQ6XC7xixN7Yxf4opBD-5OBC_o8G9Sh1Kp4vYUSR47e6mc7g2UzVAhaZuBXDh3x-fRSkRxRGL2hVrdQFy-Wto-UfFTEXoGj2jRBF49F2nS4ykPhUM5XkmdHRe6z9jXsd5EL=w410-h879-no)

------------------------------------

### Authors
Designed by #NVJOB Nicholas Veselov | https://nvjob.pro | http://nvjob.dx.am | https://twitter.com/nvjob

### License
This project is licensed under the MIT License - see the LICENSE file for details
