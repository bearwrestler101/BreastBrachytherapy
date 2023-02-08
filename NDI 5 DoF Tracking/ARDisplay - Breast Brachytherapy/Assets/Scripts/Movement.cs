using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Movement : MonoBehaviour
{
    public GameObject NDI;
    // Start is called before the first frame update
    void Start()
    {
        NDI.transform.Translate(0.0f, 0.0f, 8.0f, Space.World);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
