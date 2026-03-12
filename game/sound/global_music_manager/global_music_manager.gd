extends Node

enum BUS_ID {MASTER, MUSIC, SFX_ALL, SFX_ENEMIES, SFX_UI, ENVIRONMENT}

@onready var init_bus_volumes:Array[float] 
var active_player:MusicPlayer
var fading_player:MusicPlayer
var current_track: SongList.TRACK
var is_playing:bool = false


enum TRANSITIONS {
	CROSSFADE,
	FADE_AND_START,
	INSTANT
	}

enum TWEEN_TYPES {PLAYER_FADE, BUS_FADE}

var active_tweens: Array[Array]


func _ready():
	for i in AudioServer.bus_count:
		init_bus_volumes.append(AudioServer.get_bus_volume_db(i))


func fade_bus_volume(_bus_id:BUS_ID, _duration:float, _target_db:float = 30, _to_init_volume:bool = false) -> void:
	for tween in active_tweens:
		if tween.has(_bus_id):
			await tween[1].finished
	
	var tween = get_tree().create_tween()
	
	active_tweens.append([TWEEN_TYPES.BUS_FADE,tween, _bus_id])
	
	
	tween.set_ignore_time_scale(true)
	
	if _to_init_volume:
		_target_db = init_bus_volumes[_bus_id]
	
	tween.tween_method(func(v): AudioServer.set_bus_volume_db(_bus_id, v),  AudioServer.get_bus_volume_db(_bus_id),  _target_db,  _duration)
	
	await tween.finished
	active_tweens.erase([TWEEN_TYPES.BUS_FADE,tween, _bus_id])

func fade_player_volume(_duration:float, _target_volume_db:float = -60, _player:MusicPlayer = active_player, _stop:bool = false) -> void: ## fades the volume of [param _player] by [param _target_volume_db] in a span of time equal to [param _duration] in seconds. Will queue [param _player] to be freed if [param _stop] is true. 
	for tween in active_tweens:
		if tween.has(_player):

			await tween[1].finished

	var tween = get_tree().create_tween()
	
	active_tweens.append([TWEEN_TYPES.PLAYER_FADE, tween, _player])
	
	tween.set_ignore_time_scale(true)
	tween.tween_property(_player, "volume_db", _target_volume_db, _duration)
	
	await tween.finished
	active_tweens.erase([TWEEN_TYPES.PLAYER_FADE, tween, _player])
	
	if _stop:
		_player.stop()
		_player.queue_free()
	


func make_music_player(_song:SongList.TRACK) -> MusicPlayer:
	var new_stream_player := MusicPlayer.new(SongList.get_song_resource(_song))
	new_stream_player.bus = "Music"
	add_child(new_stream_player)
	return new_stream_player
	
	
## Request music track given by [param _track_name] with transition defined by [param _transition] [br]
## Transitions take different paramters in the Array [param _transition_parameters] depending on type: [br]
## CROSSFADE takes one float defining its duration, [br]
## FADE_AND_START takes one float for the duration of the fade_player_volume out and one float for the offset of the incoming track start [br]
## INSTANT doesn't need parameters
func request_music(_track_name:SongList.TRACK, _transition : TRANSITIONS, _transition_paramteres:Array = [], _with_env_nose: bool = false, _custom_transition:StringName = ""):
	
	
	if not is_playing:
		active_player = make_music_player(_track_name)
		is_playing = true
		active_player.start_playback()
		
		
	elif !current_track == _track_name:
		
		fading_player = active_player
		active_player = make_music_player(_track_name)
		
		
		if _custom_transition != "":
			pass
		else:
			match _transition:
				TRANSITIONS.CROSSFADE:
					fade_player_volume(_transition_paramteres[0], -60 ,fading_player, true)
					active_player.volume_db = -60
					active_player.start_playback()
					fade_player_volume(_transition_paramteres[0], 0, active_player)
					
				TRANSITIONS.FADE_AND_START:
					fade_player_volume(_transition_paramteres[0], -60 ,fading_player, true)
					await get_tree().create_timer(_transition_paramteres[1]).timeout
					active_player.start_playback()
					
				TRANSITIONS.INSTANT:
					active_player.start_playback()
					fading_player.stop()
					fading_player.queue_free()
	current_track = _track_name

func fade_out(_duration:float,_stop:bool = false) -> void: ## Fades out the currently playing music track. [param _stop] will stop playback after the fade is complete.
	fade_player_volume(_duration, -60, active_player, _stop)

func fade_in(_duration : float) -> void: ## Fades in the currently playing music track. Only works if there is a faded out active music track
	if active_player != null:
		fade_player_volume(_duration, 0, active_player)
	


	
func focus_on_bus(_bus : BUS_ID, _duration:float, _reduction_db:float) -> void:
	var other_buses  := BUS_ID.values().duplicate()
	other_buses.erase(_bus)
	other_buses.erase(BUS_ID.MASTER)
	other_buses.erase(AudioServer.get_bus_index(AudioServer.get_bus_send(_bus)))
	for i in other_buses:
		fade_bus_volume(i, 0.4, init_bus_volumes[i]-_reduction_db)

	await get_tree().create_timer(_duration).timeout
	
	for i in other_buses:
		fade_bus_volume(i, 0.4, 0, true)
