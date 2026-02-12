class_name SoundSequence extends Node

@export var audio_stream_player: AudioStreamPlayer
var counter:int = 0

@export var audio_streams: Array[AudioStream]
var playback :AudioStreamPlaybackPolyphonic
func _ready():
	audio_stream_player.play()
	audio_stream_player
	playback  = audio_stream_player.get_stream_playback()

func play(from_position = 0.0) -> void:
	playback.play_stream(audio_streams[counter])
	counter+= 1
	
	if counter == audio_streams.size():
		counter = 0
		
