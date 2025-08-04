extends Node2D

@export var speed := 5.0
@export var range := 3.0

@export var collect_sfx: AudioStream

var initial_y: float
var accumulator := 0.0

func _ready():
	initial_y = global_position.y

func _process(delta):
	accumulator += delta * speed
	global_position.y = initial_y + sin(accumulator) * range

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player") and not body.is_dead:
		SfxManager.play(collect_sfx)
		if SceneManager.load_next_level:
			SceneManager.load_next_scene()
		else:
			SceneManager.load_scene(0)
