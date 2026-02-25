class_name MusicPlayer extends AudioStreamPlayer


func _init(_song: AudioStreamInteractive):
	stream = _song
	

func start_playback():
	if stream:
		play()
		update_track_tail_volume()




func update_track_tail_volume():	
	#lower tail volume of previous track
	#var current_clip_stream = get_current_clip_stream()
	#if current_clip_stream is AudioStreamSynchronized: 
		#current_clip_stream.set_sync_stream_volume(1,-60.0)
	#
	var timer = get_tree().create_timer(get_current_clip_stream().get_length()+10)
	await timer.timeout

	var current_clip_stream = get_current_clip_stream()
	
	if current_clip_stream is AudioStreamSynchronized: 

		current_clip_stream.set_sync_stream_volume(1,10.0)


func get_current_clip_stream() -> AudioStream:
	return  stream.get_clip_stream(get_stream_playback().get_current_clip_index())
