using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine;

public class RobotGetPosition : MonoBehaviour
{
    public Single[] values = new Single[7];
    public GameObject RobotCommObject;
    public Vector3 localPosition = new Vector3(0, 0, 0);
    public Quaternion localRotation = new Quaternion(0, 0, 0,1);
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if(RobotCommObject != null)
        {
            RobotComm robotComm = RobotCommObject.GetComponent<RobotComm>();
            localPosition = robotComm.GetRobotPosition();
            localRotation = robotComm.GetRobotRotation();
            //float[] values = plusClient.GetTracker3Values();
            //transform.localPosition = kinectClient.GetHeadPosition();
            //localPosition = kinectClient.GetHeadPosition();
        }
        //localPosition = transform.position;

        //Quaternion rotVal = new Quaternion();
        transform.localPosition = localPosition;
        transform.localRotation = localRotation;
    }
}
