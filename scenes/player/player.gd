extends CharacterBody2D

# Node references
@onready var ray_cast_lt := $RayCastLT
@onready var ray_cast_rt := $RayCastRT
@onready var ray_cast_lb := $RayCastLB
@onready var ray_cast_rb := $RayCastRB
@onready var collision_shape := $CollisionShape2D
@onready var anim_sprite := $AnimatedSprite2D

# Movement
@export var speed := 90.0
@export var acceleration := 20.0
@export var friction := 1000.0
@export var air_control_factor := 0.5
@export var max_fall_speed := 200.0

# Jump
@export var jump_force := 270.0
@export var jump_cut_factor := 0.3
@export var coyote_time := 0.1
@export var jump_buffer_time := 0.1
@export var hang_gravity_factor := 0.5
@export var hang_velocity_threshold := 50.0

# Wall jump
@export var wall_jump_x_speed := 150.0
@export var wall_jump_y_speed := 270.0
@export var wall_jump_time := 0.1
@export var wall_jump_control_factor := 0.2
@export var max_wall_slide_speed := 60.0

# Audio
@export var jump_sfx: AudioStream
@export var death_sfx: AudioStream

# Animation
@export var scale_speed := 15.0
@export var squash_time := 0.08

# State
var is_dead := false
var death_rotation_speed: float
var wall_jump_timer := 0.0
var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var squash_timer := 0.0
var was_on_floor := false

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _process(delta: float):
	if Input.is_action_just_pressed("reset"):
		die()
		await get_tree().create_timer(1.5).timeout
		SceneManager.restart_current_scene()
	
	_handle_animation(delta)
	_handle_landing_detection()

func _physics_process(delta: float):
	if is_dead:
		_handle_death_physics(delta)
		return
	
	var control_factor := 1.0
	
	_handle_gravity_and_timers(delta)
	_handle_wall_sliding()
	_handle_jump_input(delta)
	_handle_movement_input(delta)
	move_and_slide()

#region Input Handling
func _handle_movement_input(delta: float):
	var control_factor = _get_control_factor()
	var dir = Input.get_axis("move_left", "move_right")
	if dir != 0:
		velocity.x = lerp(velocity.x, dir * speed, acceleration * control_factor * delta)
	else:
		_apply_friction(control_factor, delta)

func _handle_jump_input(delta: float):
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta
		
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= jump_cut_factor
	
	if jump_buffer_timer > 0.0:
		_attempt_jump()

func _attempt_jump():
	var near_wall_left = ray_cast_lb.is_colliding() or ray_cast_lt.is_colliding()
	var near_wall_right = ray_cast_rb.is_colliding() or ray_cast_rt.is_colliding()
	
	if coyote_timer > 0.0:
		_jump()
	elif near_wall_left:
		_wall_jump(1)
	elif near_wall_right:
		_wall_jump(-1)
#endregion

#region Physics
func _handle_gravity_and_timers(delta: float):
	var gravity_scale = gravity
	
	if is_on_floor():
		coyote_timer = coyote_time
		was_on_floor = true
	else:
		coyote_timer -= delta
		if abs(velocity.y) < hang_velocity_threshold:
			gravity_scale = gravity * hang_gravity_factor
		was_on_floor = false
	
	velocity.y += gravity_scale * delta
	
	if wall_jump_timer > 0:
		wall_jump_timer -= delta

func _handle_wall_sliding():
	if is_on_wall_only():
		velocity.y = min(velocity.y, max_wall_slide_speed)
	else:
		velocity.y = min(velocity.y, max_fall_speed)

func _get_control_factor() -> float:
	var control_factor := 1.0 if is_on_floor() else air_control_factor
	if wall_jump_timer > 0:
		control_factor *= wall_jump_control_factor
	return control_factor

func _apply_friction(control_factor: float, delta: float):
	var friction_force = friction * control_factor * delta
	if velocity.x > 0:
		velocity.x = max(0, velocity.x - friction_force)
	elif velocity.x < 0:
		velocity.x = min(0, velocity.x + friction_force)

func _handle_death_physics(delta: float):
	velocity.y += gravity * delta
	rotation_degrees += death_rotation_speed * delta
	move_and_slide()
#endregion

#region Movement Actions
func _jump():
	jump_buffer_timer = 0.0
	coyote_timer = 0.0
	velocity.y = -jump_force
	
	_play_jump_effects()
	_squash(Vector2(1.2, 0.8))

# wall_dir: +1 for left, -1 for right
func _wall_jump(wall_dir: int):
	jump_buffer_timer = 0.0
	coyote_timer = 0.0
	
	velocity.x = wall_jump_x_speed * wall_dir
	velocity.y = -wall_jump_y_speed
	
	wall_jump_timer = wall_jump_time
	_play_jump_effects()
	_squash(Vector2(1.3, 0.7))

func die():
	if is_dead:
		return
	is_dead = true
	
	_disable_collision()
	_apply_death_physics()
	SfxManager.play(death_sfx)
	CameraManager.start_shake(4, 0.1)

func _disable_collision():
	collision_layer = 0
	collision_mask = 0
	collision_shape.disabled = true

func _apply_death_physics():
	velocity = Vector2(
		randf_range(100, 200) * (1.0 if randf() > 0.5 else -1.0),
		randf_range(-400, -200)
	)
	death_rotation_speed = randf_range(300, 600) * (1.0 if randf() > 0.5 else -1.0)
#endregion

#region Animation + Effects
func _handle_animation(delta: float):
	if squash_timer > 0.0:
		squash_timer -= delta
	else:
		anim_sprite.scale = anim_sprite.scale.lerp(Vector2.ONE, scale_speed * delta)

func _handle_landing_detection():
	if not was_on_floor and is_on_floor():
		_squash(Vector2(1.2, 0.8))
		CameraManager.start_shake(0.5, 0.2)

func _squash(new_scale: Vector2):
	squash_timer = squash_time
	anim_sprite.scale = new_scale

func _play_jump_effects():
	SfxManager.play(jump_sfx)
	CameraManager.start_shake(0.35, 0.15)
#endregion
