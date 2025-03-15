extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_force: float = 4.5
@export var gravity: float = 9.8
@export var mouse_sensitivity: float = 0.005
@export var bullet_tscn: PackedScene  # Assign Bullet.tscn in the inspector

@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/Camera3D  # Reference to the camera

var rotation_yaw: float = 0.0
var rotation_pitch: float = 0.0
var recoil_force: Vector3 = Vector3.ZERO  # Stores recoil force
var recoil_decay: float = 0.9  # How fast recoil fades (0-1)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotation_yaw -= event.relative.x * mouse_sensitivity
		rotation_pitch -= event.relative.y * mouse_sensitivity
		rotation_pitch = clamp(rotation_pitch, deg_to_rad(-89), deg_to_rad(89))  # Prevent camera flip

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

	# Apply movement input
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force

	# ✅ Apply recoil properly
	velocity += recoil_force

	# ✅ Gradually reduce recoil effect
	recoil_force *= recoil_decay * delta # This prevents a sharp stop

	move_and_slide()  # Move the player

	# Apply rotation to camera
	rotation.y = rotation_yaw
	camera_pivot.rotation.x = rotation_pitch

	# Keep CameraPivot in sync with the player's position
	camera_pivot.global_transform.origin = global_transform.origin

func shoot():
	if not %Trident:
		return
	
	# Get the PackedScene from %Trident
	var bullet_tscn = %Trident.scene_file_path
	var bullet_scene = load(bullet_tscn)
	if not bullet_scene:
		return
	
	# Instantiate a new bullet
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)

	# Set bullet's starting position to %Trident's position
	bullet.global_transform = %Trident.global_transform

	# Make the bullet move in the direction of the camera
	bullet.linear_velocity = -camera.global_transform.basis.z * bullet.speed

	# ✅ Apply recoil when shooting
	apply_recoil()


func apply_recoil():
	var recoil_strength = 10.0  # Increase for a stronger knockback
	recoil_force = camera.global_transform.basis.z * recoil_strength  # Push opposite to bullet direction
