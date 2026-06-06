class_name MusicPlayer extends AudioStreamPlayer
## Class instanced by GlobalMusicManager for music playback.

func _init(song: Song):
	stream = song
	volume_db = song.volume
	



## Starts playback. Queues transition to next track if the current [member Song] is oneshot.
func start_playback():
	if stream is Song:
		play()
		if stream.oneshot:
			on_finished(stream)

## Waits for the song to finish and requests transition to the next track.
func on_finished(song:Song):

	await get_tree().create_timer(song.length).timeout
	GlobalMusicManager.request_music(song.next_track,song.transition)
