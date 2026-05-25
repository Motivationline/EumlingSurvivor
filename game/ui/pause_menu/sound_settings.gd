extends TabBar
@export var vol_min:float
@export var vol_max:float

# Called when the node enters the scene tree for the first time.

func _ready():

	$SliderContainer/MusicContainer/MusicSlider.value  = convert_to_value(GlobalMusicManager.init_bus_volumes[GlobalMusicManager.BUS_ID.MUSIC])
	$SliderContainer/SFXContainer/SFXSlider.value = convert_to_value(GlobalMusicManager.init_bus_volumes[GlobalMusicManager.BUS_ID.SFX_ALL])
	$SliderContainer/AmbienceContainer/AmbienceSlider.value = convert_to_value(GlobalMusicManager.init_bus_volumes[GlobalMusicManager.BUS_ID.ENVIRONMENT])




func on_slider_changed(value:float, source:String) -> void:
	var volume:float
	if value == 0 :
		volume = -100
	else:
		volume =   convert_to_volume_db(value)
	match source:
		"Music":
			AudioServer.set_bus_volume_db(GlobalMusicManager.BUS_ID.MUSIC,volume)
		"SFX":
			AudioServer.set_bus_volume_db(GlobalMusicManager.BUS_ID.SFX_ALL,volume)
		"Ambience":
			AudioServer.set_bus_volume_db(GlobalMusicManager.BUS_ID.ENVIRONMENT,volume)

func convert_to_volume_db(value:float) -> float:
	var volume:float = (100-value)/100 * (vol_min-vol_max) +vol_max

	return volume
	
func convert_to_value(volume:float) -> float:
	var value = 100-(100*(volume-vol_max)/(vol_min-vol_max))
	return value
