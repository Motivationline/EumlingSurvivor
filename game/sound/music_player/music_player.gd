class_name MusicPlayer extends AudioStreamPlayer


func _init(song: Song):
	stream = song





func start_playback():
	if stream is Song:
		play()
		if stream.oneshot:
			on_finished(stream)


func on_finished(song:Song):

	await get_tree().create_timer(song.length).timeout
	GlobalMusicManager.request_music(song.next_track,song.transition)
