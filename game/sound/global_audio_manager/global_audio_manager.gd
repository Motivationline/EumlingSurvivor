extends Node

enum BUS_ID {MASTER, MUSIC, SFX_ALL, SFX_ENEMIES, SFX_GENERAL, ENVIRONMENT}
@onready var init_bus_volumes:Array[float] 
@export var music_player: MusicPlayer

var music_playing:bool:
	get:
		return music_player.playing

func _ready():
	for i in AudioServer.bus_count:
		init_bus_volumes.append(AudioServer.get_bus_volume_db(i))

func fade_bus_volume(_bus_ids:Array[GlobalAudioManager.BUS_ID], _out:bool , _duration:float, _amount_db:float = 30, _to_init_volume:bool = false) -> Tween:

	var tween = get_tree().create_tween()
	tween.set_ignore_time_scale(true)
	for id in _bus_ids:
		if _to_init_volume:
			_amount_db = init_bus_volumes[id]
		if _out:
			tween.tween_method(func(v): AudioServer.set_bus_volume_db(id, v),  init_bus_volumes[id],  -_amount_db,  _duration)
			
		else:
			tween.tween_method(func(v): AudioServer.set_bus_volume_db(id, v),  AudioServer.get_bus_volume_db(id),  _amount_db,  _duration)
			
	return tween

func stop_music():
	music_player.stop()



func request_music(_track_name = null,_transition := MusicPlayer.TRANSITIONS.INSTANT, _transition_time:float = 0, _with_env_nose: bool = false ):

	if !_track_name == null:
		music_player.queue_specific_track(_track_name, _transition, _transition_time, _with_env_nose)
	else:
		music_player.queue_random_track()
