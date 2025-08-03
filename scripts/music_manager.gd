extends Node

@onready var music_player = AudioStreamPlayer.new()
var is_muted := false

func _ready():
	add_child(music_player)
	
	music_player.stream = load("res://assets/audio/music.wav")
	music_player.volume_db = -0.45
	music_player.autoplay = false
	
	play_music()

func play_music():
	if not music_player.playing:
		music_player.play()
		
func stop_music():
	music_player.stop()

func toggle_mute():
	is_muted = !is_muted
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), is_muted)
