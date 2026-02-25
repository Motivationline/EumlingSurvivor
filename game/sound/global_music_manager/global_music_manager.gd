extends Node

enum BUS_ID {MASTER, MUSIC, SFX_ALL, SFX_ENEMIES, SFX_GENERAL, ENVIRONMENT}

@onready var init_bus_volumes:Array[float] 
var active_player:MusicPlayer
var fading_player:MusicPlayer
var current_track: SongList.TRACK
var is_playing:bool = false

signal fade_done

enum TRANSITIONS {
	CROSSFADE,
	FADE_AND_START,
	INSTANT
	}




func _ready():
	for i in AudioServer.bus_count:
		init_bus_volumes.append(AudioServer.get_bus_volume_db(i))



func fade_bus_volume(_bus_ids:Array[BUS_ID], _out:bool , _duration:float, _amount_db:float = 30, _to_init_volume:bool = false):
	var tween = get_tree().create_tween()
	tween.set_ignore_time_scale(true)
	for id in _bus_ids:
		if _to_init_volume:
			_amount_db = init_bus_volumes[id]
		if _out:
			tween.tween_method(func(v): AudioServer.set_bus_volume_db(id, v),  init_bus_volumes[id],  -_amount_db,  _duration)
			
		else:
			tween.tween_method(func(v): AudioServer.set_bus_volume_db(id, v),  AudioServer.get_bus_volume_db(id),  _amount_db,  _duration)
			



func fade(_duration:float, _target_volume_db:float = -60, _player:MusicPlayer = active_player, _stop:bool = false) -> void: ## fades the volume of [param _player] by [param _target_volume_db] in a span of time equal to [param _duration] in seconds. Will queue [param _player] to be freed if [param _stop] is true. 
	
	var tween = get_tree().create_tween()
	tween.set_ignore_time_scale(true)
	tween.tween_property(_player, "volume_db", _target_volume_db, _duration)
	await tween.finished
	fade_done.emit()
	if _stop:
		_player.stop()
		_player.queue_free()
	


func make_music_player(_song:SongList.TRACK):
	var new_stream_player := MusicPlayer.new(SongList.get_song_resource(_song))
	active_player = new_stream_player
	active_player.bus = "Music"
	add_child(active_player)
	
	
## Request music track given by [param _track_name] with transition defined by [param _transition] [br]
## Transitions take different paramters in the Array [param _transition_parameters] depending on type: [br]
## CROSSFADE takes one float defining its duration, [br]
## FADE_AND_START takes one float for the duration of the fade out and one float for the offset of the incoming track start [br]
## INSTANT doesn't need parameters
func request_music(_track_name:SongList.TRACK, _transition : TRANSITIONS, _transition_paramteres:Array = [], _with_env_nose: bool = false, _custom_transition:StringName = ""):
	if active_player:
		fading_player = active_player
	make_music_player(_track_name)
	
	
	if _custom_transition != "":
		pass
	if not is_playing:
		is_playing = true
		active_player.start_playback()
	elif !current_track == _track_name:
		
		match _transition:
			TRANSITIONS.CROSSFADE:
				fade(_transition_paramteres[0], -60 ,fading_player, true)
				active_player.volume_db = -60
				active_player.start_playback()
				fade(_transition_paramteres[0], 0, active_player)
				
			TRANSITIONS.FADE_AND_START:
				fade(_transition_paramteres[0], -60 ,fading_player, true)
				await get_tree().create_timer(_transition_paramteres[1]).timeout
				active_player.start_playback()

				

				
			TRANSITIONS.INSTANT:
				active_player.start_playback()
				fading_player.stop()
				fading_player.queue_free()
		current_track = _track_name
