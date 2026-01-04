@tool
extends EventStrategy
## Triggers a State from the State Machine
class_name PlaySoundEventStrategy

@export var sound_manager: SoundEffectManager

func _ready() -> void:
	pass

func event_triggered(_data):
	sound_manager.play_sound(_data)
	await sound_manager.sound_list[_data].finished


# Protocol:
#	DeactivateEvent only deactivates _process function
#	event data is hardcoded in on_hurt and on_hit
#	how to play sound? ?.?
#	not compatible with strategy system?!
#	await --------
