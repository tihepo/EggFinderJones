extends RigidBody3D

@export var speed: float = 20.0  # Bullet speed
@export var knockback_force: float = 30.0  # Knockback applied to enemies

# Called when the bullet is ready
func _ready():
	linear_velocity = -global_transform.basis.z * speed
	# Bullet will auto-delete after 5 seconds
	await get_tree().create_timer(5.0).timeout
	queue_free()

# When the bullet hits something
func _on_Bullet_body_entered(body: Node) -> void:
	if body is CharacterBody3D:
		if body.has_method("apply_knockback"):  
			body.apply_knockback(-global_transform.basis.z * knockback_force)

	queue_free()  # Destroy bullet after hitting anything
