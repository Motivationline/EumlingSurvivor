extends Control
var is_open = false
@export var sound_effect_manager:SoundEffectManager
signal return_home

func _ready():
	close ()
	
func _process(_delta):
	if Input.is_action_just_pressed("scribbleOverlayUpgrade"):
		if is_open:
			close()
		else:
			open()

func open():
	sound_effect_manager.play_sound("Open")
	visible = true
	is_open = true
	get_tree().paused = true
	
func close():
	if is_open:
		sound_effect_manager.play_sound("Close")
	get_tree().paused = false
	visible = false
	is_open = false


func _on_resume_button_pressed() -> void:
	close()


func _on_home_button_pressed() -> void:
	close()
	return_home.emit()
