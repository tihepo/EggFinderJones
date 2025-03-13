extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_force: float = 4.5
@export var gravity: float = 9.8
@export var mouse_sensitivity: float = 0.005

@onready var camera_pivot = $CameraPivot # A helper node for rotation

var rotation_yaw: float = 0.0 # Left-right rotation
var rotation_pitch: float = 0.0 # Up-down rotation

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # Hide and lock cursor

func _input(event):
	if event is InputEventMouseMotion:
		rotation_yaw -= event.relative.x * mouse_sensitivity
		rotation_pitch -= event.relative.y * mouse_sensitivity
		rotation_pitch = clamp(rotation_pitch, -1.2, 1.2) # Prevent camera flipping

func _physics_process(delta):
	var direction = Vector3.ZERO

	# Get input
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x

	direction.y = 0 # Prevent vertical movement from affecting input
	direction = direction.normalized()

	# Apply movement
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force

	# Move the character
	move_and_slide()

	# Rotate player and camera
	rotation.y = rotation_yaw
	camera_pivot.rotation.x = rotation_pitch
