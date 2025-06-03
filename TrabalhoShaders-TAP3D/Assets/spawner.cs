using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class spawner : MonoBehaviour
{
    public GameObject enemyPrefab;
    
    // Start is called before the first frame update
    void Start()
    {
        StartCoroutine(SpawnEnemy());
    }
    
    IEnumerator SpawnEnemy()
    {
        while (1 + 1 == 2)
        {
            yield return new WaitForSeconds(2.5f);
            // In a sphere 
            Vector3 spawnPosition = transform.position + Random.insideUnitSphere * 8f;
            
            Instantiate(enemyPrefab, spawnPosition, Quaternion.identity);
        }
    }
}
