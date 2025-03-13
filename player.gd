extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_force: float = 4.5
@export var gravity: float = 9.8
@export var mouse_sensitivity: float = 0.005
@export var bullet_tcsn: PackedScene  # Assign Bullet.tscn in the inspector

@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/Camera3D  # Reference to the camera

var rotation_yaw: float = 0.0
var rotation_pitch: float = 0.0

var knockback_applied: bool = false  # To check if knockback has been applied
var knockback_vector: Vector3 = Vector3.ZERO  # The knockback force vector

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotation_yaw -= event.relative.x * mouse_sensitivity
		rotation_pitch -= event.relative.y * mouse_sensitivity
		rotation_pitch = clamp(rotation_pitch, -1.2, 1.2)

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		shoot()

func _physics_process(delta):
	var direction = Vector3.ZERO

	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x

	direction.y = 0
	direction = direction.normalized()

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force

	# Apply knockback if it's set
	if knockback_applied:
		velocity += knockback_vector
		knockback_applied = false  # Reset knockback after applying it

	# Move the character (no need to pass velocity directly to move_and_slide)
	move_and_slide()

	# Apply the rotation to the player and camera
	rotation.y = rotation_yaw
	camera_pivot.rotation.x = rotation_pitch

func shoot():
	var bullet = bullet_tcsn.instantiate()
	get_parent().add_child(bullet)

	# Set the bullet's starting position to the camera's position
	bullet.global_transform.origin = camera.global_transform.origin

	# Make the bullet move toward the direction where the camera is looking
	bullet.linear_velocity = -camera.global_transform.basis.z * bullet.speed

	# Pass the player (shooter) reference to the bullet
	bullet.shooter = self  # 'self' refers to the player who shot the bullet


# Apply knockback to the shooter (the player who shot the bullet)
func apply_knockback() -> void:
	if shooter:
		# Apply knockback in the opposite direction of the bullet's velocity
		knockback_vector = -global_transform.basis.z * 50.0  # Adjust knockback strength as needed
		knockback_applied = true  # Set flag to apply knockback in the next physics frame
