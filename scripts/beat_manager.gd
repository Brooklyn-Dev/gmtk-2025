extends Node

signal beat_tick(beat_count)

@export var bpm := 100
var beat_interval_seconds := 60.0 / bpm

var beat_timer := 0.0
var beat_count := 0

func _process(delta):
	beat_timer += delta
	if beat_timer >= beat_interval_seconds:
		beat_timer -= beat_interval_seconds
		beat_count += 1
		emit_signal("beat_tick", beat_count)
