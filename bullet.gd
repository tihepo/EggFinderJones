extends RigidBody3D

@export var speed: float = 20.0  # Speed of the bullet

# Called when the bullet is ready (just after it's spawned)
func _ready():
	# Set the bullet’s initial velocity based on the camera direction
	linear_velocity = -global_transform.basis.z * speed

# When the bullet hits something
func _on_Bullet_body_entered(body: Node) -> void:
	# If the bullet hits an object (not important here, but you can add checks if needed)
	if body is CharacterBody3D:  
		# Bullet disappears after it hits something (destroy it)
		queue_free()

	# Bullet disappears after hitting anything
	queue_free()
