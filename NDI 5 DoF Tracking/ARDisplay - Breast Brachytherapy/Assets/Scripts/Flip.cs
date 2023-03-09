// source: https://answers.unity.com/questions/476810/flip-a-mesh-inside-out.html
// helpful for correct syntax: https://docs.unity3d.com/ScriptReference/ContextMenu.html

// context menu is at gear of the script component attached to the object


using UnityEngine;
using System.Linq;
using System.Collections;

public class Flip : MonoBehaviour
{
    [ContextMenu("Flip")]
    public void FlipMeshContext()
    {
        Mesh mesh = GetComponent<MeshFilter>().mesh;
        mesh.triangles = mesh.triangles.Reverse().ToArray();
    }
}
