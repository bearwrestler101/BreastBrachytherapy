using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraDebug : MonoBehaviour
{

    public bool mirrorCamera;
    Vector3 camPosition;
    public float speed = 1.0f;
    public Matrix4x4 originalProjection;
    public Matrix4x4 currentProjection;

    public Vector3 testPoint = new Vector3(10,30,0);
    public Vector3 screenPos;
    public Rect cameraRect;
    Camera cam;

    private bool oldCulling;

    // Start is called before the first frame update
    void Start()
    {
        cam = GetComponent<Camera>();
        camPosition = transform.position;
        originalProjection = cam.projectionMatrix;
        currentProjection = originalProjection;
    }

    void OnPreRender()
    {
        if (mirrorCamera)
        {
            oldCulling = GL.invertCulling;
            GL.invertCulling = true;
        }
    }

    public void OnPostRender()
    {
        if (mirrorCamera)
        {
            GL.invertCulling = oldCulling;
        }
    }

    // Update is called once per frame
    void Update()
    {
        float xTrans = Input.GetAxis("Horizontal") * speed;
        float yTrans = Input.GetAxis("Vertical") * speed;
        float zTrans = Input.GetAxis("Mouse ScrollWheel") * speed * 100;

        xTrans *= Time.deltaTime;
        yTrans *= Time.deltaTime;
        zTrans *= Time.deltaTime;

        camPosition = camPosition + new Vector3(xTrans, yTrans, zTrans);

        transform.position = camPosition;

        cameraRect = cam.pixelRect;
        if (mirrorCamera)
        {
            cam.projectionMatrix = currentProjection * Matrix4x4.Scale(new Vector3(-1, 1, 1)); //Works
        }
        screenPos = cam.WorldToViewportPoint(testPoint);

    }
}
