extends Control


func _on_close_button_pressed() -> void:
	Main.controller.load_scene(Main.controller.main_menu, false)
