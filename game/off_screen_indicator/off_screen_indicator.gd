@tool
##Attach this to a 3D Node to create a ui element pointing at it when it is off screen.
class_name OffScreenIndicator extends VisibleOnScreenNotifier3D

@export var active: bool = false:
	set(value):
		active = value
		if value and !is_on_screen():
			_on_screen_exited()
		else:
			_on_screen_entered()

##The Node this icon points at. If empty, it defaults to its own position.
@export var pointing_target: Node3D


@export_category("Icon")
@export var icon: TextureRect
@export var texture: Texture2D

##The direction the texture is pointing at. Used to rotate it toward the object properly.
@export var texture_pointing_direction: Vector2


@export_category("Margin")

enum MARGIN_MODE {CIRCULAR, RECTANGULAR}

##The way the the indicator moves around the screen. Can either be circular around the center or contained within a rectangular bounding box
@export var margin_mode: MARGIN_MODE:
	set(value):
		margin_mode = value
		notify_property_list_changed()

#Boundary info
var margin_horizontal: int = 200
var margin_vertical: int = 200
var radius: float = 500.0

#Viewport info
var viewport_center: Vector2
var viewport_size: Vector2
var camera: Camera3D

func _get_property_list():
	var properties: Array[Dictionary] = []
	
	match margin_mode:
		MARGIN_MODE.CIRCULAR:
			properties.append({
				"name": "icon_radius",
				"type": TYPE_FLOAT,
				"hint": "The radius around the center of the screen where the icon is displayed"
			})
		MARGIN_MODE.RECTANGULAR:
			properties.append({
				"name": "margin_horizontal_px",
				"type": TYPE_INT,
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "0, 500, 1, or_greater, suffix:px"
			})
			properties.append({
				"name": "margin_vertical_px",
				"type": TYPE_INT,
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "0, 500, 1, or_greater, suffix:px"
			})
	return properties


func _get(property):
	if property.begins_with("icon_radius"):
		return radius
	if property.begins_with("margin_horizontal_px"):
		return margin_horizontal
	if property.begins_with("margin_vertical_px"):
		return margin_vertical
	return null

func _set(property, value):
	if property.begins_with("icon_radius"):
		radius = value
		return true
	if property.begins_with("margin_horizontal_px"):
		margin_horizontal = value
		return true
	if property.begins_with("margin_vertical_px"):
		margin_vertical = value
		return true
	return false

func _property_can_revert(property):
	if property.begins_with("icon_radius"):
		return true
	if property.begins_with("margin_horizontal_px"):
		return true
	if property.begins_with("margin_vertical_px"):
		return true
	return false
func _property_get_revert(property):
	if property.begins_with("icon_radius"):
		return 500.0
	if property.begins_with("margin_horizontal_px"):
		return 200
	if property.begins_with("margin_vertical_px"):
		return 200
	return null

func _ready() -> void:
	icon.texture = texture
	icon.offset_transform_position = - icon.size / 2.0


	if !pointing_target:
		pointing_target = self
	
	if !Engine.is_editor_hint():
		_on_viewport_resized()
		get_viewport().size_changed.connect(_on_viewport_resized)
		camera = (get_tree().get_first_node_in_group("Level") as Level).find_child("GameCamera")
		if is_on_screen():
			_on_screen_entered()
		else:
			_on_screen_exited()
	else:
		notify_property_list_changed()
		process_mode = Node.PROCESS_MODE_DISABLED
		

func _physics_process(_delta: float) -> void:
	if !Engine.is_editor_hint():
		var screen_position: Vector2 = camera.unproject_position(pointing_target.global_position)
		var icon_position: Vector2
		
		icon.rotation = viewport_center.direction_to(screen_position).angle() + texture_pointing_direction.angle()
		
		match margin_mode:
			MARGIN_MODE.CIRCULAR:
				icon_position = viewport_center + viewport_center.direction_to(screen_position) * radius
			MARGIN_MODE.RECTANGULAR:
				var a: Vector2 = Vector2(margin_horizontal, margin_vertical)
				var b: Vector2 = Vector2(viewport_size.x - margin_horizontal, margin_vertical)
				var c: Vector2 = Vector2(viewport_size.x - margin_horizontal, viewport_size.y - margin_vertical)
				var d: Vector2 = Vector2(margin_horizontal, viewport_size.y - margin_vertical)
				var corners = [a, b, c, d]
				var intersection
				for i in 2:
					intersection = Geometry2D.segment_intersects_segment(corners[i], corners[i + 1], viewport_center, screen_position)
					if intersection:
						icon_position = intersection
						break
		
		icon.position = icon_position


func _on_screen_entered():
	if icon:
		icon.hide()
		process_mode = Node.PROCESS_MODE_DISABLED


func _on_screen_exited():
	if active and icon:
		icon.show()
		process_mode = Node.PROCESS_MODE_INHERIT
	

func _on_viewport_resized() -> void:
	viewport_center = get_viewport().get_visible_rect().get_center()
	viewport_size = get_viewport().get_visible_rect().size
