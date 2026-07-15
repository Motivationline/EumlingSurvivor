class_name SoundRequester extends Node

@export var anim_tree:AnimationTree
signal play_sound(sound:Variant, focus: bool, persistent: bool)
signal stop_sound(sound:Variant)

func emit_play_sound(sound:Variant, focus: bool = false , persistent: bool = false) -> void:
	play_sound.emit(sound, focus, persistent)

func emit_stop_sound(sound:Variant) -> void:
	stop_sound.emit(sound)
