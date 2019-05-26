# NVJOB Water Shader - simple and fast.

Version 1.4.2

Simple and fast water shader. This shader is suitable for scenes where water is not a key element of the scene, but a decorative element. Supported rendering path deferred and forward.

https://www.youtube.com/watch?v=94dRrLFMA1k<br>
https://www.youtube.com/watch?v=q91znPUJtPY

![GitHub Logo](https://lh3.googleusercontent.com/X5ONnzhu3aaY87bpzubHSoVlA8Nc_0mVP5ADV626Dn6ly57vGJKhwgthWS8BiGZ7UrrArpZETGFH5a6TtibOAXcw5e_l5pHZEU6fCr91WHDdczpiNGAlNaK7kheCN3N8ldQuOH_mc9sGmhT1FSk5HB7EWvrrg-zegpsMuZup5O83zwFCa-ExMpOxkJXyMZBX0lfU0PqepxDlGhaadlQHjMLHHKD9646D7-urQTE_7sp_aKojvEItUadLwroaRkMesXcogcMGO89yNXBzOwmXaEnPlM11mA67cyrvTRvW1uIwJZBGPPMIEjI3OBxzOIfE2yhBMDgpa7T2sQM-ZonRmtmXOmY8n2OoxUmt5O-FI-o0eAgVNZONrqUvwUgGtnWkzjG8T2k3IBbiTcGG_memcCRLiS8C9tQUnPqtzqXAQf1GpK-28nEI46HC0yFWB6CrhFV5X7CfcncDAYGgPY3VKR4bTYry4UJXx4NGKuNGDPwHJDApFDTkoS8ytjDouEPM6F80gpDI7JMiWGZfvxFpEchQsm3FsnNdKJetPAWN7hMbkCLOOTrRJNtqsWjmQ2G6OXyg1T4tmEiUWVp_I6_I8u54AkVUFzOaUfAstyQy7PPTbzW922plK_tdnT0tos4BTlTzFHLCAL35mvSkDlHwC8TrajKyPLuJFB8jl7j6FhCnXfj0zMtZL7Vw7ipJth717wQiMAhvuO3lMvvyEDskt0L5=w1637-h918-no)

![GitHub Logo](https://lh3.googleusercontent.com/GmuNJh12m17qrHh3RwMnxorHgqHJ1wdcb1Wk9u79tez58O-A3n3UDgoWv44aTDqS_QwyrIIcdrzedKEV_NWtfJ3hOu8SsOgtuvuwj9BPpMOOjewTXQ5QO571t56DlKdOzeRnuOzAKfnWkJDhb9otFNiY9kWPsGqxJOKUbS77BPzaJlelDTQTkiWS556ituJ-3k5SbuSPFWNLwnLW9Ew1eF3vXvmiLlNPjA83NiqDXkPTLfgyDrbmwDtuMAuvR1_k9H59Ti3JrOFncsFUMLKUe7qihnovw0UcSfQK0Tg5fe05RZmH6k2ZJrZwUHQKiI4RVyf3riqkneMuAWo4-s3OTbRCqqwYVwosfiJ0ruqIvMzE-vPiY7cZLD5-24DGwr9CG8mGM4ZwSd3fPKB12HMCEbzk6YRN4lIX9YevwTQ5ORmoATv89RNIHOEiDMQXBHJJJm8nz_-S6kK6-Gjgvw0FneAkquhPu01A38DYEeMp1JWKHjZCDQytvusQM93TpQQIdah09g4bYvdxoOTA0n2MIfVlGjBo0DiYXTWDxW5Gc40zxQLeUip78TAyEfQU8U5YEgAEA4o13YYzwQ6l_5bz6qK1VlaFt8g4lDv7EJ5Rtf8LFF5TxxecbRLxvRHmCWXRJA6CcoViXqUi6othjrVi-AgICFmL50mFm55M337Hpx2YUI6OfpkMscb7B8-Pwvh_SgdGZKPMPKbNenJXRdkLyOkw=w1637-h918-no)

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
