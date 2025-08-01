extends CharacterBody2D

@export var speed := 180.0
@export var acceleration := 12.0
@export var friction := 24.0
@export var air_control_factor := 0.7
@export var jump_force := 300.0
@export var jump_cut_factor := 0.4

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= jump_cut_factor
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_force
	
	var control_factor = 1.0 if is_on_floor() else air_control_factor
	
	var dir = Input.get_axis("move_left", "move_right")
	if dir != 0:
		velocity.x = lerp(velocity.x, dir * speed, acceleration * control_factor * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, friction * control_factor * delta)
	
	move_and_slide()
