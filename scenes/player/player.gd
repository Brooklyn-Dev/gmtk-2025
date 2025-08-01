extends CharacterBody2D

@export var speed := 120.0
@export var acceleration := 20.0
@export var friction := 32.0
@export var air_control_factor := 0.7
@export var jump_force := 280.0
@export var jump_cut_factor := 0.3
@export var coyote_time := 0.1
@export var jump_buffer_time := 0.1
@export var max_fall_speed := 400.0
@export var hang_gravity_factor := 0.5
@export var hang_velocity_threshold := 50.0

var coyote_timer := 0.0
var jump_buffer_timer := 0.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	var control_factor = 1.0
	var gravity_scale = gravity
	
	if is_on_floor():
		coyote_timer = coyote_time
		control_factor = air_control_factor
	else:
		coyote_timer -= delta
		if abs(velocity.y) < hang_velocity_threshold:
			gravity_scale = gravity * hang_gravity_factor
	
	velocity.y += gravity_scale * delta
	velocity.y = min(velocity.y, max_fall_speed)
	
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta
		
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= jump_cut_factor
	
	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
		velocity.y = -jump_force
	
	var dir = Input.get_axis("move_left", "move_right")
	if dir != 0:
		velocity.x = lerp(velocity.x, dir * speed, acceleration * control_factor * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, friction * control_factor * delta)
	
	move_and_slide()
