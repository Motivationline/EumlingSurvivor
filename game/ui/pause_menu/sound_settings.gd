extends TabBar
@export var vol_min:float
@export var vol_max:float

@export var pause_menu:Control
@export var music_slider: HSlider
@export var sfx_slider: HSlider
@export var ambience_slider: HSlider

@export var sound_effect_manager:SoundEffectManager
@export var slider_tick_stream_player:AudioStreamPlayer

func _ready():
	music_slider.value  = convert_to_value(GlobalMusicManager.init_bus_volumes[GlobalMusicManager.BUS_ID.MUSIC])
	sfx_slider.value = convert_to_value(GlobalMusicManager.init_bus_volumes[GlobalMusicManager.BUS_ID.SFX_ALL])
	ambience_slider.value = convert_to_value(GlobalMusicManager.init_bus_volumes[GlobalMusicManager.BUS_ID.ENVIRONMENT])

	



func on_slider_changed(value:float, source:String) -> void:
	if pause_menu.is_open:
		var volume:float
		if value == 0 :
			volume = -100
		else:
			volume =   convert_to_volume_db(value)
		match source:
			"Music":
				slider_tick_stream_player.bus = AudioServer.get_bus_name( GlobalMusicManager.BUS_ID.MUSIC)
				sound_effect_manager.play_sound("SliderTick")
				AudioServer.set_bus_volume_db(GlobalMusicManager.BUS_ID.MUSIC,volume)
			"SFX":
				slider_tick_stream_player.bus = AudioServer.get_bus_name( GlobalMusicManager.BUS_ID.SFX_ALL)
				sound_effect_manager.play_sound("SliderTick")
				AudioServer.set_bus_volume_db(GlobalMusicManager.BUS_ID.SFX_ALL,volume)
			"Ambience":
				slider_tick_stream_player.bus = AudioServer.get_bus_name( GlobalMusicManager.BUS_ID.ENVIRONMENT)
				sound_effect_manager.play_sound("SliderTick")
				AudioServer.set_bus_volume_db(GlobalMusicManager.BUS_ID.ENVIRONMENT,volume)

func convert_to_volume_db(value:float) -> float:
	var volume:float = (100-value)/100 * (vol_min-vol_max) +vol_max

	return volume
	
func convert_to_value(volume:float) -> float:
	var value = 100-(100*(volume-vol_max)/(vol_min-vol_max))
	return value
