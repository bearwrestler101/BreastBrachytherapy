using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraMovement_sag : MonoBehaviour
{
    public Transform NDI;
    // Start is called before the first frame update
    void Start()
    {
        //start_pos = transform.position.z;

    }

    // Update is called once per frame
    void Update()
    {
        //transform.position = new Vector3(NDI.position.x, 0.0f, NDI.position.z);
        Quaternion q = transform.rotation;
        q.eulerAngles = new Vector3(0, NDI.eulerAngles.y+90, 0);
        transform.rotation = q;
    }
}


