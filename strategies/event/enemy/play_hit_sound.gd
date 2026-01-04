@tool
extends EventStrategy
## Triggers a State from the State Machine
class_name PlayHitSoundEventStrategy

@export var sound_manager: SoundEffectManager

func _ready() -> void:
	pass

func event_triggered(_data):
	sound_manager.play_sound(_data)
	await sound_manager.sound_list[_data].finished
