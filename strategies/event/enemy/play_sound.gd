@tool
extends EventStrategy
## Triggers a State from the State Machine
class_name PlaySoundEventStrategy

@export var sound_manager: SoundEffectManager
@export var sound_to_play: String
@export var needs_to_be_persistent: bool = false

func _ready() -> void:
	pass

func event_triggered(_data):
	sound_manager.play_sound(sound_to_play, false, needs_to_be_persistent)


# Protocol:
#	DeactivateEvent only deactivates _process function
#	event data is hardcoded in on_hurt and on_hit
#	how to play sound? ?.?
#	not compatible with strategy system?!
#	await --------
