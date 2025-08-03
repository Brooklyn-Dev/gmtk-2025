extends Node

const NUM_CHANNELS = 8
var bus = "Master"

var available = []
var queue = []

var is_muted := false

func _ready():
	for i in NUM_CHANNELS:
		var p = AudioStreamPlayer.new()
		add_child(p)
		available.append(p)
		p.finished.connect(_on_stream_player_finished.bind(p))
		p.bus = bus

func _on_stream_player_finished(stream_player: AudioStreamPlayer):
	available.append(stream_player)

func play(audio_stream: AudioStream):
	if is_muted:
		return
	
	queue.append(audio_stream)

func _process(delta):
	if not queue.is_empty() and not available.is_empty():
		var player = available.pop_back()
		player.stream = queue.pop_front()
		player.play()

func toggle_mute():
	is_muted = !is_muted
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), is_muted)
