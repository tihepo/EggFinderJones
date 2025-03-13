extends TextureRect  # Use Sprite2D if in 2D

func _process(delta):
	position = get_global_mouse_position()  # Moves the crosshair to the cursor
