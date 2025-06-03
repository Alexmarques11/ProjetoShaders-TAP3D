using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;

public class NauseaEffectActivate : MonoBehaviour
{
    public Material postProcessMaterial;
    public string playerTag = "Player";
    public string sceneToLoad = "NextSceneName";
    private Coroutine loadSceneCoroutine;

    void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag(playerTag))
        {
            if (postProcessMaterial != null)
            {
                Debug.Log("Nausea effect activated for player.");
                postProcessMaterial.SetFloat("_NauseaEffect", 1);
            }

            loadSceneCoroutine = StartCoroutine(LoadSceneAfterDelay(3f));
        }
    }

    void OnTriggerExit(Collider other)
    {
        if (other.CompareTag(playerTag))
        {
            if (postProcessMaterial != null)
            {
                Debug.Log("Nausea effect deactivated for player.");
                postProcessMaterial.SetFloat("_NauseaEffect", 0);
            }
            if (loadSceneCoroutine != null)
            {
                StopCoroutine(loadSceneCoroutine);
                loadSceneCoroutine = null;
            }
        }
    }

    IEnumerator LoadSceneAfterDelay(float delay)
    {
        yield return new WaitForSeconds(delay);
        postProcessMaterial.SetFloat("_NauseaEffect", 0);
        Debug.Log("Changing scene...");
        SceneManager.LoadScene(sceneToLoad);
    }
}
