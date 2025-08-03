extends CharacterBody2D

@onready var ray_cast_lt := $RayCastLT
@onready var ray_cast_rt := $RayCastRT
@onready var ray_cast_lb := $RayCastLB
@onready var ray_cast_rb := $RayCastRB

@onready var collision_shape := $CollisionShape2D
@onready var anim_sprite := $AnimatedSprite2D

@export var jump_sfx: AudioStream
@export var death_sfx: AudioStream

@export var speed := 90.0
@export var acceleration := 20.0
@export var friction := 1000.0
@export var air_control_factor := 0.5
@export var max_fall_speed := 200.0

@export var jump_force := 270.0
@export var jump_cut_factor := 0.3
@export var wall_jump_x_speed := 150.0
@export var wall_jump_y_speed := 270.0
@export var wall_jump_time := 0.1
@export var wall_jump_control_factor := 0.2
@export var max_wall_slide_speed := 60.0

@export var coyote_time := 0.1
@export var jump_buffer_time := 0.1

@export var hang_gravity_factor := 0.5
@export var hang_velocity_threshold := 50.0

var wall_jump_timer := 0.0

var coyote_timer := 0.0
var jump_buffer_timer := 0.0

var is_dead := false
var death_rotation_speed: float

var scale_speed := 15.0
var squash_time := 0.08
var squash_timer := 0.0

var was_on_floor := false

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _process(delta):
	if Input.is_action_just_pressed("reset"):
		die()
		await get_tree().create_timer(1.5).timeout
		SceneManager.restart_current_scene()
	
	if squash_timer > 0.0:
		squash_timer -= delta
	else:
		anim_sprite.scale = anim_sprite.scale.lerp(Vector2.ONE, scale_speed * delta)
	
	if not was_on_floor and is_on_floor():
		_squash(Vector2(1.2, 0.8))
		CameraManager.start_shake(0.5, 0.2)

func _physics_process(delta):
	if is_dead:
		velocity.y += gravity * delta
		rotation_degrees += death_rotation_speed * delta
		move_and_slide()
		return
	
	var control_factor := 1.0
	var gravity_scale = gravity
	
	if is_on_floor():
		coyote_timer = coyote_time
		was_on_floor = true
	else:
		coyote_timer -= delta
		control_factor = air_control_factor
		if abs(velocity.y) < hang_velocity_threshold:
			gravity_scale = gravity * hang_gravity_factor
		was_on_floor = false
	
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
	
	SfxManager.play(jump_sfx)
	CameraManager.start_shake(0.4, 0.15)
	_squash(Vector2(1.2, 0.8))

# wall_dir: +1 for left, -1 for right
func _wall_jump(wall_dir: int):
	jump_buffer_timer = 0.0
	coyote_timer = 0.0
	
	velocity.x = wall_jump_x_speed * wall_dir
	velocity.y = -wall_jump_y_speed
	
	wall_jump_timer = wall_jump_time
	SfxManager.play(jump_sfx)
	CameraManager.start_shake(0.4, 0.15)
	_squash(Vector2(1.3, 0.7))

func die():
	if is_dead:
		return
	is_dead = true
	
	collision_layer = 0
	collision_mask = 0
	collision_shape.disabled = true
	
	velocity = Vector2(
		randf_range(100, 200) * (1.0 if randf() > 0.5 else -1.0),
		randf_range(-400, -200)
	)

	death_rotation_speed = randf_range(300, 600) * (1.0 if randf() > 0.5 else -1.0)
	
	SfxManager.play(death_sfx)
	CameraManager.start_shake(4, 0.1)

func _squash(new_scale):
	squash_timer = squash_time
	anim_sprite.scale = new_scale
