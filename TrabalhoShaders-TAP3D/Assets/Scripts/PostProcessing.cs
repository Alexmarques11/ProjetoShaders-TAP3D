using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostProcessing : MonoBehaviour
{
    public Material mat;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, mat);
    }

    void Update()
    {
        if (Input.GetButton("Fire1"))
        {
            Vector3 mousePos = Input.mousePosition;
            mousePos.x = mousePos.x;
            mousePos.y = mousePos.y;

            mat.SetVector("CentroXY", new Vector4(mousePos.x, mousePos.y, 0, 0));

            Debug.Log("x" + mousePos.x);
            Debug.Log("y" + mousePos.y);

        }
    }
}
