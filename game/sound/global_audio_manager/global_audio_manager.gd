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

func fade_bus_volume(bus_ids:Array[GlobalAudioManager.BUS_ID], _out:bool , _duration:float,_amount_db:float = 100, _to_init_volume:bool = false) -> Tween:


	var tween = get_tree().create_tween()
	tween.set_ignore_time_scale(true)
	for id in bus_ids:
		if _to_init_volume:
			_amount_db = init_bus_volumes[id]
		if _out:
			tween.tween_method(func(v): AudioServer.set_bus_volume_db(id, v),  init_bus_volumes[id],  -_amount_db,  _duration)
			
		else:
			tween.tween_method(func(v): AudioServer.set_bus_volume_db(id, v),  AudioServer.get_bus_volume_db(id),  _amount_db,  _duration)
			
	return tween

func stop_music():
	music_player.stop()



func request_music(track_name = null,transition := MusicPlayer.TRANSITIONS.INSTANT, transition_time:float = 0,with_env_nose: bool = false ):

	if !track_name == null:
		music_player.queue_specific_track(track_name, transition, transition_time, with_env_nose)
	else:
		music_player.queue_random_track()
