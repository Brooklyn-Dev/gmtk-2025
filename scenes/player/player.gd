extends CharacterBody2D

@onready var ray_cast_lt := $RayCastLT
@onready var ray_cast_rt := $RayCastRT
@onready var ray_cast_lb := $RayCastLB
@onready var ray_cast_rb := $RayCastRB

@export var speed := 100.0
@export var acceleration := 20.0
@export var friction := 1000.0
@export var air_control_factor := 0.5
@export var max_fall_speed := 250.0

@export var jump_force := 270.0
@export var jump_cut_factor := 0.3
@export var wall_jump_x_speed := 160.0
@export var wall_jump_y_speed := 265.0
@export var wall_jump_time := 0.1
@export var wall_jump_control_factor := 0.05
@export var max_wall_slide_speed := 80.0

@export var coyote_time := 0.08
@export var jump_buffer_time := 0.1

@export var hang_gravity_factor := 0.5
@export var hang_velocity_threshold := 50.0

var wall_jump_timer := 0.0

var coyote_timer := 0.0
var jump_buffer_timer := 0.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	var control_factor := 1.0
	var gravity_scale = gravity
	
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta
		control_factor = air_control_factor
		if abs(velocity.y) < hang_velocity_threshold:
			gravity_scale = gravity * hang_gravity_factor
	
	velocity.y += gravity_scale * delta
	if is_on_wall_only():
		velocity.y = min(velocity.y, max_wall_slide_speed)
	else:
		velocity.y = min(velocity.y, max_fall_speed)
	
	var near_wall_left = ray_cast_lb.is_colliding() or ray_cast_lt.is_colliding()
	var near_wall_right = ray_cast_rb.is_colliding() or ray_cast_rt.is_colliding()
	
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta
		
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= jump_cut_factor
	
	if jump_buffer_timer > 0.0:
		if coyote_timer > 0.0:
			_jump()
		elif near_wall_left:
			_wall_jump(1)
		elif near_wall_right:
			_wall_jump(-1)
	
	if wall_jump_timer > 0:
		wall_jump_timer -= delta
		control_factor *= wall_jump_control_factor
	
	var dir = Input.get_axis("move_left", "move_right")
	
	if dir != 0:
		velocity.x = lerp(velocity.x, dir * speed, acceleration * control_factor * delta)
	else:
		var friction_force = friction * control_factor * delta
		if velocity.x > 0:
			velocity.x = max(0, velocity.x - friction_force)
		elif velocity.x < 0:
			velocity.x = min(0, velocity.x + friction_force)
		
	move_and_slide()

func _jump():
	jump_buffer_timer = 0.0
	coyote_timer = 0.0
	velocity.y = -jump_force

# wall_dir: +1 for left, -1 for right
func _wall_jump(wall_dir: int):
	jump_buffer_timer = 0.0
	coyote_timer = 0.0
	
	velocity.x = wall_jump_x_speed * wall_dir
	velocity.y = -wall_jump_y_speed
	
	wall_jump_timer = wall_jump_time
