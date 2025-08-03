extends Node

var camera: Camera2D = null
var shake_amount: float = 0.0
var shake_decay: float = 5.0
var shake_speed: float = 50.0
var shake_offset: Vector2 = Vector2.ZERO
var lean_offset: Vector2 = Vector2.ZERO

func _process(delta):
	if camera == null:
		camera = get_viewport().get_camera_2d()
		if camera == null:
			return
			
	if shake_amount > 0:
		shake_offset = Vector2(
			randf_range(-shake_amount, shake_amount),
			randf_range(-shake_amount, shake_amount)
		)
		shake_offset = shake_offset.lerp(Vector2.ZERO, delta * shake_speed)
		
		shake_amount = max(shake_amount - shake_decay * delta, 0)
	else:
		shake_offset = Vector2.ZERO
	
	camera.offset = lean_offset + shake_offset

func start_shake(amount: float, duration: float = 0.2):
	shake_amount = amount
	await get_tree().create_timer(duration).timeout
	shake_amount = 0
