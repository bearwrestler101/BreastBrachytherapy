

//Works but not perfectly
//using UnityEngine;

//public class CameraMovement_egg : MonoBehaviour
//{
//    public Transform NDI;
//    public Transform cylinder;
//    public float minXLimit = 44.83f; // Minimum x-axis limit
//    public float maxXLimit = 47.86f; // Maximum x-axis limit
//    public float minZLimit = 0.67f;  // Minimum z-axis limit
//    public float maxZLimit = 2.92f;  // Maximum z-axis limit
//    public float cameraOffset = 90f; // Offset angle for camera rotation

//    private void Update()
//    {
//        // Get the position of NDI and cylinder
//        Vector3 NDIposition = new Vector3(NDI.position.x, transform.position.y, NDI.position.z);
//        Vector3 cylinderPosition = new Vector3(cylinder.position.x, transform.position.y, cylinder.position.z);

//        // Calculate the vector from cylinder to NDI
//        Vector3 vectorBetween = NDIposition - cylinderPosition;

//        // Calculate the destination point for the camera
//        Vector3 destination = NDIposition /*+ vectorBetween*/;

//        // Check if NDI is within the bounding box
//        bool withinBounds = IsWithinBounds(NDIposition);

//        if (!withinBounds)
//        {
//            // Extend the vector to the nearest wall of the bounding box
//            destination = ExtendVectorToNearestWall(NDIposition, vectorBetween);
//        }

//        // Set the position of the camera to the destination
//        transform.position = destination;

//        // Calculate the desired rotation for the camera
//        Quaternion desiredRotation = Quaternion.Euler(0f, NDI.eulerAngles.y + cameraOffset, 0f);

//        // Apply the rotation to the camera
//        transform.rotation = desiredRotation;

//        // Draw the vector as a line
//        Debug.DrawLine(cylinderPosition, cylinderPosition + vectorBetween, Color.red);
//    }

//    private bool IsWithinBounds(Vector3 position)
//    {
//        // Check if the given position is within the bounding box
//        return position.x >= minXLimit && position.x <= maxXLimit &&
//               position.z >= minZLimit && position.z <= maxZLimit;
//    }

//    private Vector3 ExtendVectorToNearestWall(Vector3 origin, Vector3 vector)
//    {
//        // Calculate the distances to both walls
//        float distanceToMinX = Mathf.Abs(minXLimit - origin.x);
//        float distanceToMaxX = Mathf.Abs(maxXLimit - origin.x);
//        float distanceToMinZ = Mathf.Abs(minZLimit - origin.z);
//        float distanceToMaxZ = Mathf.Abs(maxZLimit - origin.z);

//        // Find the nearest wall based on the distances
//        float projectedX = distanceToMinX < distanceToMaxX ? minXLimit : maxXLimit;
//        float projectedZ = distanceToMinZ < distanceToMaxZ ? minZLimit : maxZLimit;

//        // Calculate the extended destination along the wall
//        Vector3 extendedDestination = origin + vector.normalized * Vector3.Distance(origin, new Vector3(projectedX, origin.y, projectedZ));

//        // Project the extended destination onto the box in case it exceeds the limits
//        Vector3 projectedDestination = ProjectVectorOntoBox(extendedDestination, minXLimit, maxXLimit, minZLimit, maxZLimit);

//        return projectedDestination;
//    }

//    private Vector3 ProjectVectorOntoBox(Vector3 vector, float minX, float maxX, float minZ, float maxZ)
//    {
//        // Project the vector onto the box
//        float projectedX = Mathf.Clamp(vector.x, minX, maxX);
//        float projectedZ = Mathf.Clamp(vector.z, minZ, maxZ);
//        return new Vector3(projectedX, vector.y, projectedZ);
//    }

//    private void OnDrawGizmos()
//    {
//        Gizmos.color = Color.yellow;

//        // Draw the boundary box
//        Vector3 boxCenter = new Vector3((minXLimit + maxXLimit) / 2, transform.position.y, (minZLimit + maxZLimit) / 2);
//        Vector3 boxSize = new Vector3(maxXLimit - minXLimit, 0.1f, maxZLimit - minZLimit);
//        Gizmos.DrawWireCube(boxCenter, boxSize);
//    }
//}

using UnityEngine;

public class CameraMovement_egg : MonoBehaviour
{
    public Transform NDI;
    public Transform cylinder;
    public float minXLimit = 44.83f; // Minimum x-axis limit
    public float maxXLimit = 47.86f; // Maximum x-axis limit
    public float minZLimit = 0.67f;  // Minimum z-axis limit
    public float maxZLimit = 2.92f;  // Maximum z-axis limit
    public float cameraOffset = 90f; // Offset angle for camera rotation

    private Vector3 betweenVector;
    private Vector3 perpendicularVector;
    private Vector3 lineCenter;
    private Vector3 intersectionPoint;
    private Vector3 perpendicularVectorAtCenter;

    private void Update()
    {
        Vector3 NDIposition = new Vector3(NDI.position.x, transform.position.y, NDI.position.z);
        Vector3 cylinderPosition = new Vector3(cylinder.position.x, transform.position.y, cylinder.position.z);

        // Calculate the vector from cylinder to NDI
        betweenVector = NDIposition - cylinderPosition;

        // Calculate perpendicular vector
        perpendicularVector = new Vector3(-betweenVector.z, 0f, betweenVector.x).normalized;
       
        // Calculate line center within the bounding box
        lineCenter = new Vector3((minXLimit + maxXLimit) / 2f, transform.position.y, (minZLimit + maxZLimit) / 2f);

        //// Camera movements restricted to the line defined by the perpendicular vector
        //Vector3 targetPosition = lineCenter + perpendicularVector;
        //targetPosition.x = Mathf.Clamp(targetPosition.x, minXLimit, maxXLimit);
        //targetPosition.z = Mathf.Clamp(targetPosition.z, minZLimit, maxZLimit);
        //targetPosition.y = transform.position.y;
        //transform.position = targetPosition;


        // Calculate intersection point in the x-z plane
        //intersectionPoint = lineCenter + (Vector3.Dot(perpendicularVector, NDIposition - lineCenter) / perpendicularVector.sqrMagnitude) * perpendicularVector;
        intersectionPoint = lineCenter + Vector3.Project(NDIposition - lineCenter, perpendicularVector);


        //Restrict intersection point to the defined boundaries in the x-z plane
        intersectionPoint.x = Mathf.Clamp(intersectionPoint.x, minXLimit, maxXLimit);
        intersectionPoint.z = Mathf.Clamp(intersectionPoint.z, minZLimit, maxZLimit);
        intersectionPoint.y = transform.position.y;


        // Restrict camera movement to the perpendicular vector
        Vector3 targetPosition = lineCenter + Vector3.Project(intersectionPoint - lineCenter, perpendicularVector);
        targetPosition.x = Mathf.Clamp(targetPosition.x, minXLimit, maxXLimit);
        targetPosition.z = Mathf.Clamp(targetPosition.z, minZLimit, maxZLimit);
        targetPosition.y = transform.position.y;


        // Update camera position to the target position with the same y-axis position
        transform.position = new Vector3(targetPosition.x, transform.position.y, targetPosition.z);



        // Update camera position to the intersection point with the same y-axis position
        //transform.position = new Vector3(intersectionPoint.x, transform.position.y, intersectionPoint.z);


        // Calculate the desired rotation for the camera
        Quaternion desiredRotation = Quaternion.Euler(0f, NDI.eulerAngles.y + cameraOffset, 0f);

        // Apply the rotation to the camera
        transform.rotation = desiredRotation;

        // Visualize the line along which the camera moves
        Debug.DrawLine(lineCenter - perpendicularVector * 5f, lineCenter + perpendicularVector * 5f, Color.red);
        Debug.DrawLine(NDIposition, NDIposition + betweenVector, Color.red);

        Debug.DrawLine(NDIposition, NDIposition + perpendicularVector, Color.green); // Perpendicular vector
        Debug.DrawLine(NDIposition, intersectionPoint, Color.blue); // Intersection line
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.yellow;

        // Draw the boundary box
        Vector3 boxCenter = new Vector3((minXLimit + maxXLimit) / 2, transform.position.y, (minZLimit + maxZLimit) / 2);
        Vector3 boxSize = new Vector3(maxXLimit - minXLimit, 0.1f, maxZLimit - minZLimit);
        Gizmos.DrawWireCube(boxCenter, boxSize);

        Gizmos.color = Color.red;

        // Visualize the intersection point with a sphere
        Gizmos.DrawSphere(intersectionPoint, 0.5f);
    }

}




