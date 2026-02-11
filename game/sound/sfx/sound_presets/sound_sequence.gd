class_name SoundSequence extends Node

@export var audio_stream_player: AudioStreamPlayer
var counter:int = 0

@export var audio_streams: Array[AudioStream]

func play(from_position = 0.0) -> void:
	audio_stream_player.stream = audio_streams[counter]
	audio_stream_player.play(from_position)
	counter+= 1
	
	if counter == audio_streams.size():
		counter = 0
		
