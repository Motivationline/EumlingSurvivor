@tool
extends EventStrategy
##Stops given sounds
class_name StopSoundEventStrategy

@export var sound_manager: SoundEffectManager:
	set(value):
		sound_manager = value
		update_configuration_warnings()
@export var sound_to_stop: Array[String]

func _ready() -> void:
	pass

func execute_event(_data):
	if sound_manager != null:
		sound_manager.stop_sound(sound_to_stop)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray
	if (sound_manager == null): warnings.append("Sound Manager not configured")
	return warnings
