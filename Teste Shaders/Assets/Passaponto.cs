using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PassaPonto : MonoBehaviour
{
    private void OnCollisionStay(Collision collision)
    {
        Vector3 worldPoint = collision.GetContact(0).point;
        Vector3 localPoint = transform.InverseTransformPoint(worldPoint);

        this.GetComponent<Renderer>().material.SetVector("_pontoCsharp", localPoint);

        Debug.Log($"Ponto de colisão (World): {worldPoint}");
        Debug.Log($"Ponto de colisão (Local): {localPoint}");
    }
}
