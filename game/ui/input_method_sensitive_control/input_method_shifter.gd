class_name InputMethodShifter extends Control

@export var controller_nodes: Control
@export var mouse_keyboard_nodes: Control
@export var mobile_nodes: Control


func _ready() -> void:
	add_to_group("InputMethodSensitive")
	shift(InputMethodDetector.current_input_method)


func shift(_method: InputMethodDetector.INPUT_METHOD) -> void:
	controller_nodes.hide()
	mouse_keyboard_nodes.hide()
	mobile_nodes.hide()

	match _method:
		InputMethodDetector.INPUT_METHOD.CONTROLLER:
			controller_nodes.show()
		InputMethodDetector.INPUT_METHOD.KEYBOARD:
			mouse_keyboard_nodes.show()
		InputMethodDetector.INPUT_METHOD.MOBILE:
			mobile_nodes.show()
