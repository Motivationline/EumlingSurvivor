class_name MusicPlayer extends AudioStreamPlayer


func _init(song: AudioStreamInteractive):
	stream = song


func start_playback():
	if stream:
		play()
