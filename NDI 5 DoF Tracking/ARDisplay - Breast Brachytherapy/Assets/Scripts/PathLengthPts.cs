
using UnityEngine;

public class PathLengthPts : MonoBehaviour
{
    public Transform needleTip;
    public GameObject meshObject;
    private GameObject nearestSphere;
    private GameObject furthestSphere;
    private GameObject something;
    public Material highlightMaterial;
    public float distance;


    private void Update()
    {

        // Get the position and orientation of the needle's tip in world space
        Vector3 needleTipPosition = needleTip.transform.position;
        Quaternion needleTipRotation = needleTip.transform.rotation;

        // Define the axis of the needle based on its orientation
        Vector3 needleAxis = needleTip.transform.forward; // Adjust if needed (e.g., using up vector)

        Mesh mesh = meshObject.GetComponent<MeshFilter>().sharedMesh;
        Vector3[] vertices = mesh.vertices;
        int vertexCount = vertices.Length;

        DestroySpheres();
        Vector3 closestVertex = FindNearestPoint(mesh, needleTipPosition, needleAxis);
        Vector3 furthestVertex = FindFurthestPoint(mesh, needleTipPosition, needleAxis);


        distance = Vector3.Distance(closestVertex, furthestVertex);
        print(distance);

        //Debug.DrawLine(needleTip.position, needleTip.position + needleAxis * 5f, Color.blue);

        
        //nearestSphere = HighlightVertex(closestVertex, Color.green);
        //furthestSphere = HighlightVertex(furthestVertex, Color.red);


    }

    private Vector3 FindNearestPoint(Mesh mesh, Vector3 needlePosition, Vector3 direction)
    {

        Vector3[] vertices = mesh.vertices;
        int vertexCount = vertices.Length;

        float sumX = 0f;
        float sumY = 0f;
        float sumZ = 0f;
        int count = 0;

        // Calculate the mean X and Z positions
        for (int i = 0; i < vertexCount; i++)
        {
            Vector3 vertexPosition = meshObject.transform.TransformPoint(vertices[i]);

            sumX += vertexPosition.x;
            sumY += vertexPosition.y;
            sumZ += vertexPosition.z;
            count++;
        }

        float meanX = sumX / count;
        float meanY = sumY / count;
        float meanZ = sumZ / count;

        float closestDistance = Mathf.Infinity;
        Vector3 closestVertex = Vector3.zero;
        int Loopcount = 0;

        //something = HighlightVertex(new Vector3(meanX, meanY, meanZ), Color.blue);
        // Iterate through all vertices
        for (int i = 0; i < vertexCount; i++)
        {
            // Transform the vertex from local space to world space
            Vector3 vertexPosition = meshObject.transform.TransformPoint(vertices[i]);

            //float distanceToMean = Vector3.Distance(new Vector3(meanX, meanY, meanZ), vertexPosition);
            float distanceToMean = Vector3.Distance(new Vector3(meanX, meanY, meanZ), needlePosition);

            float distanceToNeedleTip = Vector3.Distance(needlePosition, vertexPosition);
            
            if (distanceToNeedleTip < distanceToMean)
            {

                // Calculate the distance from the needle tip along the needle's axis
                Vector3 toVertex = vertexPosition - needlePosition;
                float projection = Vector3.Dot(toVertex, direction);
                Vector3 projectedPoint = needlePosition + direction * projection;
                float distance = Vector3.Distance(projectedPoint, vertexPosition);
                // Check if this vertex is closer than the previous closest one
                if (distance < closestDistance)
                {
                    closestDistance = distance;
                    closestVertex = vertexPosition;
                }
                Loopcount++;
            }
        }
        //print(Loopcount);
        return closestVertex;
    }

    private Vector3 FindFurthestPoint(Mesh mesh, Vector3 needlePosition, Vector3 direction)
    {
        Vector3[] vertices = mesh.vertices;
        int vertexCount = vertices.Length;

        float sumX = 0f;
        float sumY = 0f;
        float sumZ = 0f;
        int count = 0;

        // Calculate the mean X and Z positions
        for (int i = 0; i < vertexCount; i++)
        {
            Vector3 vertexPosition = meshObject.transform.TransformPoint(vertices[i]);

            sumX += vertexPosition.x;
            sumY += vertexPosition.y;
            sumZ += vertexPosition.z;
            count++;
        }

        float meanX = sumX / count;
        float meanY = sumY / count;
        float meanZ = sumZ / count;

        Vector3 furthestVertex = Vector3.zero;
        float furthestDistance = Mathf.Infinity;


        // Iterate through all vertices
        for (int i = 0; i < vertexCount; i++)
        {

            // Transform the vertex from local space to world space
            Vector3 vertexPosition = meshObject.transform.TransformPoint(vertices[i]);

            //float distanceToMean = Vector3.Distance(new Vector3(meanX, meanY, meanZ), vertexPosition);
            float distanceToMean = Vector3.Distance(new Vector3(meanX, meanY, meanZ), needlePosition);

            float distanceToNeedleTip = Vector3.Distance(needlePosition, vertexPosition);

            if (distanceToNeedleTip > distanceToMean)
            {

                // Calculate the distance from the needle tip along the needle's axis
                Vector3 toVertex = vertexPosition - needlePosition;
                float projection = Vector3.Dot(toVertex, direction);
                Vector3 projectedPoint = needlePosition + direction * projection;
                float distance = Vector3.Distance(projectedPoint, vertexPosition);
                // Check if this vertex is closer than the previous closest one
                if (distance < furthestDistance)
                {
                    furthestDistance = distance;
                    furthestVertex = vertexPosition;
                }
            }
        }
        return furthestVertex;
    }


    private void DestroySpheres()
    {
        if (nearestSphere != null)
        {
            Destroy(nearestSphere);
        }
        if (furthestSphere != null)
        {
            Destroy(furthestSphere);
        }
        if (something != null)
        {
            Destroy(something);
        }
    }
    private GameObject HighlightVertex(Vector3 vertexPosition, Color color)
    {
        GameObject sphere = GameObject.CreatePrimitive(PrimitiveType.Sphere);
        sphere.transform.position = vertexPosition;
        sphere.transform.localScale = Vector3.one * 0.5f;
        sphere.GetComponent<Renderer>().material = highlightMaterial;
        sphere.GetComponent<Renderer>().material.color = color;
        sphere.transform.SetParent(transform);
        return sphere;
    }
}
