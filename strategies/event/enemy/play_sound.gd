@tool
extends EventStrategy
## Plays given sounds.
class_name PlaySoundEventStrategy

@export var sound_manager: SoundEffectManager:
	set(value):
		sound_manager = value
		update_configuration_warnings()
@export var sound_to_play:Array[String] =[]
@export var needs_to_be_persistent: bool = false

func _ready() -> void:
	pass

func execute_event(_data):
	if sound_manager != null:
		sound_manager.play_sound(sound_to_play, false, needs_to_be_persistent)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray
	if (sound_manager == null): warnings.append("Sound Manager not configured")
	return warnings
