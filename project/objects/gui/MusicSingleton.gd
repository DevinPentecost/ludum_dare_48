extends Node

const BGM = preload("res://objects/gui/LD48.ogg")

var _audio_player: AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	_audio_player = AudioStreamPlayer.new()
	add_child(_audio_player)
	_audio_player.stream = BGM
	_audio_player.volume_db = -22
	_audio_player.play()
