extends Node

@onready var music_player = AudioStreamPlayer.new()

func _ready():
	add_child(music_player)
	
	music_player.stream = load("res://assets/music.wav")
	music_player.autoplay = false
	
	play_music()

func play_music():
	if not music_player.playing:
		music_player.play()
		
func stop_music():
	music_player.stop()
