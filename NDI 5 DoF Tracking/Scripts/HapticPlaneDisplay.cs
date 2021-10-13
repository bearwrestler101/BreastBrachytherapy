using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HapticPlaneDisplay : MonoBehaviour
{
    public Material matActive;
    public Material matInactive;
    Material baseMat;
    Renderer[] planeList;
    string activeName;
    public GameObject RobotCommObject;
    public bool useSimulinkPlane = true;

    // Start is called before the first frame update
    void Start()
    {
        //baseMat = GetComponent<Renderer>().material;
        activeName = "None";
    }

    // Update is called once per frame
    void Update()
    {
        if (useSimulinkPlane)
        {
            int planeNumber = 0;
            RobotComm robotComm = RobotCommObject.GetComponent<RobotComm>();

            planeNumber = robotComm.GetRobotPlane();
            switch(planeNumber)
            {
                case 1:
                    activeName = "Plane1";
                    break;
                case 2:
                    activeName = "Plane2";
                    break;
                case 3:
                    activeName = "Plane3";
                    break;
                case 4:
                    activeName = "Plane4";
                    break;
                case 5:
                    activeName = "Plane5";
                    break;
                default:
                    activeName = "None";
                    break;
            }
        }
        else
        {
            if (Input.GetKeyDown(KeyCode.Alpha1))
            {
                activeName = "Plane1";
            }

            if (Input.GetKeyDown(KeyCode.Alpha2))
            {
                activeName = "Plane2";
            }

            if (Input.GetKeyDown(KeyCode.Alpha3))
            {
                activeName = "Plane3";
            }

            if (Input.GetKeyDown(KeyCode.Alpha4))
            {
                activeName = "Plane4";
            }

            if (Input.GetKeyDown(KeyCode.Alpha5))
            {
                activeName = "Plane5";
            }
        }

        Renderer[] rendererList;
        rendererList = GetComponentsInChildren<Renderer>();
        foreach (Renderer renderer in rendererList)
        {
            if(renderer.name == activeName)
            {
                renderer.material = matActive;
            }else{
                renderer.material = matInactive;
            }
            //Debug.Log(string.Format("Child Name {0}",gameObject.name));
        }


    }

   /* Material SetAlpha(Material mat, float alpha)
    {
        Color matColor = mat.color;
        matColor.a = alpha;
        mat.color = matColor;
        return mat;
    }*/


}
