using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraMovement : MonoBehaviour
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
        transform.position = new Vector3(0.0f, 0.0f, NDI.position.z+20.0f);
    }
}
