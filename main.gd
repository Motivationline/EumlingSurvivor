extends Node
var controller: GameController

func _ready() -> void:
	if Data.is_on_mobile:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

func _shortcut_input(event: InputEvent) -> void:
	if event.is_action("fullscreen"):
		var mode := DisplayServer.window_get_mode()
		var is_windowed = mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN if is_windowed else DisplayServer.WINDOW_MODE_WINDOWED)
