////Camera moves forward with time - for demo purposes
//https://answers.unity.com/questions/296347/move-transform-to-target-in-x-seconds.html
//using System.Collections;
//using System.Collections.Generic;
//using UnityEngine;

//public class CameraMovement_axial : MonoBehaviour
//{

//    float t;
//    public Vector3 startPosition;
//    public Vector3 target;
//    public float timeToReachTarget;
//    void Start()
//    {
//        startPosition = transform.position;
//    }
//    void Update()
//    {
//        t += Time.deltaTime / timeToReachTarget;
//        transform.position = Vector3.Lerp(startPosition, target, t);
//    }
//}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraMovement_axial : MonoBehaviour
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
        //  transform.position = new Vector3(NDI.position.x, NDI.position.y, NDI.position.z + 10.0f);
        Quaternion q = transform.rotation;
        q.eulerAngles = new Vector3(0, (NDI.eulerAngles.y+180), 0);
        transform.rotation = q; 
    }
}




