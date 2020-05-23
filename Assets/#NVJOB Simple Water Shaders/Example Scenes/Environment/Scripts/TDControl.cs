using UnityEngine;

[AddComponentMenu("#NVJOB/Tools/TDControl")]


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


public class TDControl : MonoBehaviour
{
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    public bool onlyKeyboard;

    [Header("Rotation Settings")]
    public float rotationSpeed = 180;
    public Vector2 mouseVerticaleClamp = new Vector2(-20, 20);
    public float smoothMouse = 3;

    [Header("Lift Settings")]
    public bool liftOn = true;
    public Vector2 liftClamp = new Vector2(-20, 20);
    public float smoothLift = 0.5f;

    [Header("Camera Settings")]
    public Transform camTransform;
    public Vector2 camClamp = new Vector2(-20, 20);
    public float smoothCam = 0.5f;

    //--------------

    Transform tr;
    Vector3 rotationStart, positionStart, cameraStart, velocity, target;
    float mouseX, mouseY, upCh, upChCur, upChVel, camhVel;
    float camCh, camChCur;


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    void Awake()
    {
        //--------------

        tr = transform;
        rotationStart = tr.eulerAngles;
        positionStart = tr.position;
        cameraStart = camTransform.localPosition;

        //--------------
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    void LateUpdate()
    {
        //--------------

        Rotation();
        CameraTransform();
        if (liftOn == true && onlyKeyboard == false) Lift();

        //--------------
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    void Rotation()
    {
        //--------------

        if (onlyKeyboard == false)
        {
            if (Mathf.Abs(Input.GetAxis("Mouse X")) + Mathf.Abs(Input.GetAxis("Mouse Y")) > 0)
            {
                mouseX += rotationSpeed * 0.01f * Input.GetAxis("Mouse X") * 0.3f;
                mouseY -= rotationSpeed * 0.01f * Input.GetAxis("Mouse Y") * 0.3f;
            }
        }
        else
        {
            mouseX += rotationSpeed * 0.01f * Input.GetAxis("Horizontal") * 0.3f;
            mouseY += rotationSpeed * 0.01f * Input.GetAxis("Vertical") * 0.3f;
        }

        mouseY = Mathf.Clamp(mouseY, mouseVerticaleClamp.x, mouseVerticaleClamp.y);
        tr.rotation = Quaternion.Slerp(tr.rotation, Quaternion.Euler(mouseY, mouseX + rotationStart.y, 0), smoothMouse * Time.deltaTime);

        //--------------
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    void Lift()
    {
        //--------------

        upCh += Input.GetAxis("Vertical") * 0.2f;
        upCh = Mathf.Clamp(upCh, liftClamp.x, liftClamp.y);
        upChCur = Mathf.SmoothDamp(upChCur, upCh, ref upChVel, smoothLift);
        tr.position = tr.TransformDirection(new Vector3(0, positionStart.y + upChCur, 0));

        //--------------
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    void CameraTransform()
    {
        //--------------

        camCh += Input.mouseScrollDelta.y * 0.5f;
        camCh = Mathf.Clamp(camCh, camClamp.x, camClamp.y);
        camChCur = Mathf.SmoothDamp(camChCur, camCh, ref camhVel, smoothCam);
        camTransform.localPosition = new Vector3(cameraStart.x, cameraStart.y, cameraStart.z + camChCur);

        //--------------
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}