extends Node
var controller: GameController

var tutorial = Tutorial.new()
func _ready() -> void:
	if Data.is_on_mobile:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	add_child(tutorial)

func _shortcut_input(event: InputEvent) -> void:
	if event.is_action("fullscreen"):
		var mode := DisplayServer.window_get_mode()
		var is_windowed = mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN if is_windowed else DisplayServer.WINDOW_MODE_WINDOWED)
	if Input.is_action_just_pressed("debug_reset_and_restart"):
		if tutorial:
			tutorial.queue_free()
		SaveData.reset()
		Data.reset()
		get_tree().reload_current_scene()
		tutorial = Tutorial.new()
		add_child(tutorial)
