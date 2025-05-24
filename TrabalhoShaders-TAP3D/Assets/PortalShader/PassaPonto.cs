using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PassaPonto : MonoBehaviour
{
    [Header("Ripple Settings")]
    [SerializeField] private float rippleDuration = 3.0f;
    [SerializeField] private float maxRippleStrength = 0.3f;
    [SerializeField] private float rippleFrequency = 15.0f;
    [SerializeField] private float rippleSpeed = 8.0f;

    private Material materialInstance;
    private Coroutine currentRippleCoroutine;

    private void Start()
    {
        materialInstance = GetComponent<Renderer>().material;

        materialInstance.SetFloat("_EnableRipples", 0f);
        materialInstance.SetFloat("_EnableRipple", 0f);
    }

    private void OnCollisionEnter(Collision collision)
    {
        Vector3 worldPoint = collision.GetContact(0).point;
        Vector3 localPoint = transform.InverseTransformPoint(worldPoint);

        Mesh mesh = GetComponent<MeshFilter>().mesh;
        Bounds localBounds = mesh.bounds;
        Vector3 min = localBounds.min;
        Vector3 size = localBounds.size;

        float uvX = (localPoint.x - min.x) / size.x;
        float uvY = (localPoint.z - min.z) / size.z;

        uvY = 1 - uvY;
        uvX = 1 - uvX;

        uvX = Mathf.Clamp01(uvX);
        uvY = Mathf.Clamp01(uvY);

        Vector2 uvPoint = new Vector2(uvX, uvY);

        StartRippleEffect(uvPoint);

        Debug.Log($"Pedra caiu no ponto UV: {uvPoint}");
    }

    private void StartRippleEffect(Vector2 impactPoint)
    {
        if (currentRippleCoroutine != null)
        {
            StopCoroutine(currentRippleCoroutine);
        }

        currentRippleCoroutine = StartCoroutine(RippleAnimation(impactPoint));
    }

    private IEnumerator RippleAnimation(Vector2 center)
    {
        materialInstance.SetFloat("_EnableRipples", 1f);
        materialInstance.SetFloat("_EnableRipple", 1f);
        materialInstance.SetVector("_RippleCenter", center);
        materialInstance.SetFloat("_RippleFrequency", rippleFrequency);
        materialInstance.SetFloat("_RippleSpeed", rippleSpeed);

        float startTime = Time.time;
        float elapsedTime = 0f;

        while (elapsedTime < rippleDuration)
        {
            elapsedTime = Time.time - startTime;
            float progress = elapsedTime / rippleDuration;

            materialInstance.SetFloat("_RippleTime", elapsedTime);

            float currentStrength = maxRippleStrength * (1f - progress);
            currentStrength = Mathf.Max(0f, currentStrength);
            materialInstance.SetFloat("_RippleStrength", currentStrength);

            float currentFrequency = rippleFrequency * (0.5f + 0.5f * (1f - progress));
            materialInstance.SetFloat("_RippleFrequency", currentFrequency);

            yield return null;
        }

        materialInstance.SetFloat("_EnableRipples", 0f);
        materialInstance.SetFloat("_EnableRipple", 0f);
        materialInstance.SetFloat("_RippleStrength", 0f);

        currentRippleCoroutine = null;
    }

    private void OnDestroy()
    {
        if (currentRippleCoroutine != null)
        {
            StopCoroutine(currentRippleCoroutine);
        }
    }

    [ContextMenu("Test Ripple at Center")]
    public void TestRippleAtCenter()
    {
        StartRippleEffect(new Vector2(0.5f, 0.5f));
    }


    [ContextMenu("Stop Current Ripple")]
    public void StopCurrentRipple()
    {
        if (currentRippleCoroutine != null)
        {
            StopCoroutine(currentRippleCoroutine);
            materialInstance.SetFloat("_EnableRipples", 0f);
            materialInstance.SetFloat("_EnableRipple", 0f);
            materialInstance.SetFloat("_RippleStrength", 0f);
            currentRippleCoroutine = null;
        }
    }
}
