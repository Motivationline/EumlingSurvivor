extends Control
var is_open = false
@export var sound_effect_manager:SoundEffectManager
signal return_home

func _on_skip_button_pressed() -> void:
	return_home.emit()
