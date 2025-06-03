using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GoToPlayer : MonoBehaviour
{
    public float velocity;
    public float acceleration;
    public Transform playerTransform; // Reference to the player's transform
    private Rigidbody rb;
    private Vector3 direction;
    
    // Start is called before the first frame update
    void Start()
    {
        playerTransform = GameObject.FindGameObjectWithTag("Player").transform;
        rb = GetComponent<Rigidbody>();
    }
    
    private void Move()
    {
        Vector3 movement = Vector3.Lerp(rb.velocity, velocity * direction, Time.deltaTime * acceleration);
        // Player acceleration
        // float xMovement = Mathf.Lerp(player.RigidBody.velocity.x, player.Data.BaseSpeed * reusableData.SpeedMultiplier * reusableData.MovementInput.x, Time.deltaTime * player.Data.MoveAcceleration);
        // float zMovement = Mathf.Lerp(player.RigidBody.velocity.z, player.Data.BaseSpeed * reusableData.SpeedMultiplier * reusableData.MovementInput.y, Time.deltaTime * player.Data.MoveAcceleration);

        // Vector3 movement = new(xMovement - player.RigidBody.velocity.x, 0f, zMovement - player.RigidBody.velocity.z);
        Vector3 movementfinal = movement - rb.velocity;
        
        rb.AddForce(movementfinal, ForceMode.VelocityChange);
    }

    private void FixedUpdate()
    {
        Vector3 target = playerTransform.position;
        target.y = playerTransform.position.y + 1;
        // rb.AddForce((target - transform.position).normalized * a);
        // transform.forward = rb.velocity;
        
        direction = (target - transform.position).normalized;
        
        Move();
        transform.forward = rb.velocity != Vector3.zero ? rb.velocity : Vector3.forward;
    }
    
    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("ball"))
        {
            Destroy(gameObject);
        }
    }
}
