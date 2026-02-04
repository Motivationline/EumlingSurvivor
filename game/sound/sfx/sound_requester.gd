extends Node


signal play_sound(sound:String, focus: bool, persistent: bool)


func emit_play_sound(sound:String, focus: bool = false , persistent: bool = false) -> void:
	play_sound.emit(sound, focus, persistent)
