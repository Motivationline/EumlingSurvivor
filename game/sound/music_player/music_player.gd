class_name MusicPlayer extends AudioStreamPlayer


func _init(song: Song):
	stream = song
	if song.oneshot:
		finished.connect(on_finished.bind(song))



func start_playback():
	if stream:
		play()
	
func on_finished(song:Song):
	print("sent")
	GlobalMusicManager.request_music(song.next_track,song.transition)
