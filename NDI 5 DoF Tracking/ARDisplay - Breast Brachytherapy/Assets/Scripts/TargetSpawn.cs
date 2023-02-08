using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TargetSpawn : MonoBehaviour
{
    public GameObject targetPrefab;
    public GameObject seromaparent;
    public Vector3 origin = Vector3.zero;
    public float radius = 5;
    private GameObject clonetarget;
    //public Vector3 minPosition;
    //public Vector3 maxPosition;

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            
            //Vector3 randomPosition = new Vector3(
            //    Random.Range(minPosition.x, maxPosition.x),
            //    Random.Range(minPosition.y, maxPosition.y),
            //    Random.Range(minPosition.z, maxPosition.z)
            //);
            var seromatransform = seromaparent.transform.localPosition;
            Vector3 randomPosition = Random.insideUnitSphere+seromatransform;
            clonetarget = Instantiate(targetPrefab, randomPosition, Quaternion.identity);
            //clonetarget = Instantiate(targetPrefab, seromatransform, Quaternion.identity);
            print(">>\n" +seromatransform+ "\n");
            print(">>\n" + clonetarget.transform.position + "\n");

        }

        if (Input.GetKeyDown(KeyCode.A))
        {
            Destroy(clonetarget);
        }



    }
}
