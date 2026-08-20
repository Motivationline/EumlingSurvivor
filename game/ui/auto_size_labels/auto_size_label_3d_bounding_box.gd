@tool
class_name AutoSizeLabel3DBoundingBox
extends MeshInstance3D
## Visualizes the bounds of an AutoSizeLabel3D.

var material: StandardMaterial3D
var line_width: float = 0.025

func _ready() -> void:
	if not Engine.is_editor_hint():
		queue_free()
		return

	if not mesh:
		mesh = ImmediateMesh.new()

	if not material:
		material = StandardMaterial3D.new()
		material.albedo_color = Color.RED
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.cull_mode = BaseMaterial3D.CULL_DISABLED


func update(label: AutoSizeLabel3D) -> void:
	if not Engine.is_editor_hint():
		queue_free()
		return

	_update.call_deferred(label)


func _update(label: AutoSizeLabel3D) -> void:
	var left: float
	var right: float
	var top: float
	var bottom: float

	match label.horizontal_alignment:
		HORIZONTAL_ALIGNMENT_LEFT:
			left = 0.0
			right = label.label_size.x * label.pixel_size
		HORIZONTAL_ALIGNMENT_CENTER, HORIZONTAL_ALIGNMENT_FILL:
			left = -label.label_size.x * label.pixel_size * 0.5
			right = label.label_size.x * label.pixel_size * 0.5
		HORIZONTAL_ALIGNMENT_RIGHT:
			left = -label.label_size.x * label.pixel_size
			right = 0.0
	
	match label.vertical_alignment:
		VERTICAL_ALIGNMENT_TOP:
			top = 0.0
			bottom = -label.label_size.y * label.pixel_size
		VERTICAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_FILL:
			top = label.label_size.y * label.pixel_size * 0.5
			bottom = -label.label_size.y * label.pixel_size * 0.5
		VERTICAL_ALIGNMENT_BOTTOM:
			top = label.label_size.y * label.pixel_size
			bottom = 0.0

	var inner_points: Array[Vector3] = [
		Vector3(left, top, 0.0),
		Vector3(right, top, 0.0),
		Vector3(right, bottom, 0.0),
		Vector3(left, bottom, 0.0),
	]
	var outer_points: Array[Vector3] = [
		Vector3(left - line_width, top + line_width, 0.0),
		Vector3(right + line_width, top + line_width, 0.0),
		Vector3(right + line_width, bottom - line_width, 0.0),
		Vector3(left - line_width, bottom - line_width, 0.0),
	]

	material.fixed_size = label.fixed_size
	material.billboard_mode = label.billboard

	mesh.clear_surfaces()
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES, material)

	var corner_count: int = 4
	for i in range(corner_count):
		var next: int = (i + 1) % corner_count

		mesh.surface_add_vertex(outer_points[i])
		mesh.surface_add_vertex(outer_points[next])
		mesh.surface_add_vertex(inner_points[i])

		mesh.surface_add_vertex(inner_points[i])
		mesh.surface_add_vertex(outer_points[next])
		mesh.surface_add_vertex(inner_points[next])

	mesh.surface_end()
