extends Node

@export var scenes: Array[PackedScene] = []

var current_scene: Node = null
var current_index := 0
var load_next_level := true

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel") and current_index != 0:
		load_scene(0)

func load_scene(index: int):
	if index < 0 or index >= scenes.size():
		return
	
	if current_scene:
		current_scene.queue_free()
	
	current_scene = scenes[index].instantiate()
	get_tree().root.add_child(current_scene)
	current_index = index

func load_next_scene():
	var next_index = current_index + 1
	if next_index >= scenes.size():
		next_index = 0
	load_scene(next_index)

func restart_scene():
	load_scene(current_index)
