using UnityEngine;


public class Rotation : MonoBehaviour
{
    public float rot = 1;

    void Update()
    {
        transform.Rotate(Vector3.up, rot * Time.deltaTime);
    }
}
