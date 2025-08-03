extends Node

@export var scenes: Array[PackedScene] = []

var current_scene = null
var current_index = 0

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)

func goto_scene(scene: PackedScene):
	call_deferred("_goto_scene", scene)

func _goto_scene(scene: PackedScene):
	current_scene.free()
	current_scene = scene.instantiate()
	get_tree().root.add_child(current_scene)

func goto_next_scene():
	current_index += 1
	if current_index >= scenes.size():
		current_index = 0
	goto_scene(scenes[current_index])

func restart_current_scene():
	goto_scene(scenes[current_index])
