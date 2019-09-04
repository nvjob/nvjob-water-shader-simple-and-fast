# NVJOB Water Shader - simple and fast.

Version 1.4.2

Simple and fast water shader. This shader is suitable for scenes where water is not a key element of the scene, but a decorative element. Supported rendering path deferred and forward.

https://assetstore.unity.com/packages/vfx/shaders/nvjob-water-shader-simple-and-fast-149916

Previous Versions - https://github.com/nvjob/NVJOB-Water-Shader-old-versions

https://www.youtube.com/watch?v=94dRrLFMA1k<br>
https://www.youtube.com/watch?v=q91znPUJtPY

![GitHub Logo](https://lh3.googleusercontent.com/NFyzCzkGzDacddxrSqlJNLGZFR4QRqE4XM6hReYXr9I2nbq72CnIazsfONuReDQgmXfurAjmnP1LVMBfsJtqbFwv34S_crCTg0kKa8a8h7M8ZAcE4AxU28mqSZvGYaeC8LYfcOBPOSlO6Tkv6F1x4T6nY3ocfH8gfLpO2UNCkoHy5VEZJoM9nwQdUe1axWH10HuOPLM_DwtihSKjg0k8k9n8By4E1_tAfvYsvxrdDhRWuRpGqRozu5ltm4juaaO3BHhKK0EpKyaS8qJ04XPrzFo4UNWAc6ukln7oHd8_LlIaUcNLOF-f1OSfLpVLW7Cyt_8ek1BtJLo2Zg1j5obiQ_NTyQ1WSkEPmPgbPiHsUzTMOEvze1Jzs56bS6CiukDfMShgIZ4pugQYdwW8FcVE7SvxsFwOvAtBtAEE2LrNbF6z5ySZawlFggklUBdgHTZRTXjBXsPxrBTSQDB6kDudqtlD1oZKWRJPGgv9wXa66pxkSpIYAJCKzT-Flv20Rckkn5Cs2FClLrwy7VUvNLwyJRw_W9zJOBmAsQWz_1eVrZo4hxZcgX3Z_cZWeSkuqTQinGm-nn3cq3pVQKPq-Md7a-L3QQb5McvfeB35Kf-4XpAP3ObuWyGnlrjvnW4pH8wDhfGxa5bC2Y8b5uulV1e1AS7XRdslZ0PG6wRc6zEY2fJ9CR6BPWURQNXsMqqEU5QN5oUn9sIquUz3NQ_VXjS1Z_kc=w1741-h979-no)

![GitHub Logo](https://lh3.googleusercontent.com/36v0970yH-584XFfQ-pABkNPgYvKO96x3rpaNmjOSgpi5Pu9Oo3sy4cjtFx8UshUa9rThV_Btd3nqgvbBKcO8azL9qkV-Sv1QBT8heSiZPzOmPLHrauIH5ikSdjh2czqUBUiSCm5oixaMQ8E6n5P8V-uusuXpr5wEdeHx9UwimBV3V6EY8gIg9xcbC7WDg20_iATSmPzI8e3XrbOarqCun4WdcMtWNLZ69LTPxuQvFFcglRCEdlPIZtqeAl6A-HYqvZ7fy3_jyUrJ8G1SohdWu63UcMvSaMPJyMwwnM-qwf96_8A0gFdUW09E0k06HXgOaqtXZ-Exg80Cnr3om5pq-aBoZBRhJnfVrYpL1oIDO54ZN7LUdaallL4b_yT82boChsUCsVd2miyEPtpJZcvk31za_fYWtk6PKpCb80E6451ClnrHepagFQSuUDgUXjs4QYqTVpFoWVd6Toswc4Afs5Xp0Ia64Yj5XUpU3rQcBTzkz_RzE1ehrXk9f0tMD-JCobM8QIRx8B034AjY6VlX-iAeROgLiK5IJMmtZwTdGj31Jlx4n3xjv2rQ_p3C_YslxDWBtLkXgtdo5t2NxepAEfFc-WizBbqFfmvzOOfN1fYZWIZ0bkBLxQMcKOGg4BciHkv8xk5XsSJveACZzaNPYL8mOoJEwVGjKTYfdKxiTexKdHmPx5GGhFg9YSMJXHPO6cfsJtcjw4WLgdWBGMF4W1P=w1741-h979-no)

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

### Donate
You can thank me by a voluntary donation. https://nvjob.pro/donations.html
