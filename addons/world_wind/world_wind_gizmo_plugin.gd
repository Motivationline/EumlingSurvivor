extends EditorNode3DGizmoPlugin

const ARROW_LENGTH: float = 1.0
const ARROW_HEAD_LENGTH: float = 0.25
const ARROW_HEAD_WIDTH: float = 0.18

func _has_gizmo(for_node_3d: Node3D) -> bool:
	return for_node_3d is WorldWind

func _init() -> void:
	create_material("arrow", Color(0.73, 0.87, 1))
	create_icon_material("icon", preload("world_wind_gizmo.svg"))

func _redraw(gizmo: EditorNode3DGizmo) -> void:
	gizmo.clear()

	var world_wind: WorldWind = gizmo.get_node_3d()

	var lines = PackedVector3Array()

	var direction: Vector3 = world_wind.get_wind_direction().normalized()
	var shaft_end: Vector3 = direction * ARROW_LENGTH

	lines.push_back(Vector3(0, 0, 0))
	lines.push_back(shaft_end)

	var up_hint: Vector3 = Vector3.UP
	if abs(direction.dot(up_hint)) > 0.95:
		up_hint = Vector3.RIGHT

	var right: Vector3 = direction.cross(up_hint).normalized()
	var up: Vector3 = right.cross(direction).normalized()
	var head_base: Vector3 = shaft_end - (direction * ARROW_HEAD_LENGTH)

	lines.push_back(shaft_end)
	lines.push_back(head_base + (right * ARROW_HEAD_WIDTH))

	lines.push_back(shaft_end)
	lines.push_back(head_base - (right * ARROW_HEAD_WIDTH))

	lines.push_back(shaft_end)
	lines.push_back(head_base + (up * ARROW_HEAD_WIDTH))

	lines.push_back(shaft_end)
	lines.push_back(head_base - (up * ARROW_HEAD_WIDTH))

	gizmo.add_lines(lines, get_material("arrow", gizmo), false)
	gizmo.add_unscaled_billboard(get_material("icon", gizmo), 0.045)
