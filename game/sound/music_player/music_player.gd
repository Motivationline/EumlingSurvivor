class_name MusicPlayer extends AudioStreamPlayer


func _init(song: Song):
	stream = song


func start_playback():
	if stream:
		play()
