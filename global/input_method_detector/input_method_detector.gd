extends Node


##The texture placed in the [param texture_focused] of a Button displayed when a controller is hovering it.
var button_icon_layer: Texture2D


const CONTROLLER_SENS_THRESHOLD: float = 0.1

var sensitive_nodes: Array[Node] = []

enum INPUT_METHOD {MOBILE, CONTROLLER, KEYBOARD}

var current_input_method: INPUT_METHOD

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	button_icon_layer = preload("uid://rvydbyntrvex")
	if Data.is_on_mobile:
		switch_input_method(INPUT_METHOD.MOBILE)
	else:
		switch_input_method(INPUT_METHOD.KEYBOARD)
		

func _input(event):
	if (event is InputEventMouse or event is InputEventKey) and current_input_method != INPUT_METHOD.KEYBOARD:
		switch_input_method(INPUT_METHOD.KEYBOARD)
	elif (event is InputEventJoypadButton or event is InputEventJoypadMotion) and current_input_method != INPUT_METHOD.CONTROLLER:
		if event is InputEventJoypadMotion and abs(event.axis_value) < CONTROLLER_SENS_THRESHOLD:
			return
		switch_input_method(INPUT_METHOD.CONTROLLER)
		# print(event)

func refresh_sensitive_nodes() -> void:
	sensitive_nodes = get_tree().get_nodes_in_group("InputMethodSensitive")
	if current_input_method == INPUT_METHOD.CONTROLLER:
		activate_button_icons()
	else:
		deactivate_button_icons()


func switch_input_method(_new_method: INPUT_METHOD) -> void:
	current_input_method = _new_method
	match _new_method:
		INPUT_METHOD.MOBILE:
			deactivate_button_icons()
			#print("switching to mobile")
		INPUT_METHOD.CONTROLLER:
			activate_button_icons()
			#print("switching to controller")
		INPUT_METHOD.KEYBOARD:
			deactivate_button_icons()
			#print("switching to keyboard and mouse")


func activate_button_icons() -> void:
	for node in sensitive_nodes:
		if node is TextureButton:
			node.texture_focused = crop_button_texture(node.texture_normal)


func deactivate_button_icons() -> void:
	sensitive_nodes = get_tree().get_nodes_in_group("InputMethodSensitive")
	for node in sensitive_nodes:
		if node is TextureButton:
			node.texture_focused = null


func crop_button_texture(_reference: Texture2D) -> Texture2D:
	var cropped: AtlasTexture = AtlasTexture.new()
	cropped.atlas = button_icon_layer
	cropped.region.size = Vector2(_reference.get_width(), _reference.get_height())
	cropped.region.position = Vector2(button_icon_layer.get_width() - _reference.get_width(), button_icon_layer.get_height() - _reference.get_height())

	
	return cropped
