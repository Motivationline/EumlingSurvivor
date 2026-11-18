@tool
class_name MeshPolygonLine3D extends MeshInstance3D

const MAX_VERTICES := 32
var line_uniform: PackedVector2Array

func _init() -> void:
	line_uniform = PackedVector2Array()
	line_uniform.resize(MAX_VERTICES)
	mesh = ImmediateMesh.new()

@export var line: PackedVector2Array:
	set(value):
		line = value
		update()

@export
var width := 0.25

@export_tool_button("Update", "Callable") var hello_action = update

var dirty: bool = true

func _process(_delta: float) -> void:
	if dirty:
		update()
		dirty = false

func update() -> void:
	update_mesh()
	update_shader_parameters()
	
func update_mesh() -> void:
	mesh.clear_surfaces()
	
	if line.size() < 2:
		return

	var half_width := width * 0.5
	var vertices := PackedVector2Array()

	var direction := (line[1] - line[0]).normalized()
	var side := Vector2(-direction.y, direction.x) * half_width

	vertices.append(line[0] + side)
	vertices.append(line[0] - side)

	for i in range(1, line.size() - 1):
		var prev_dir := (line[i] - line[i - 1]).normalized()
		var next_dir := (line[i + 1] - line[i]).normalized()

		var side_prev := Vector2(-prev_dir.y, prev_dir.x)
		var side_next := Vector2(-next_dir.y, next_dir.x)

		var miter := (side_prev + side_next).normalized()
		var denominator := miter.dot(side_next)

		if abs(denominator) < 0.001:
			miter = side_next * half_width
		else:
			miter *= half_width / denominator

		if miter.length() > width * 2.0:
			miter = miter.normalized() * width * 2.0

		vertices.append(line[i] + miter)
		vertices.append(line[i] - miter)

	direction = (line[-1] - line[-2]).normalized()
	side = Vector2(-direction.y, direction.x) * half_width

	vertices.append(line[-1] + side)
	vertices.append(line[-1] - side)

	var start_direction := (line[1] - line[0]).normalized()
	var end_direction := (line[-1] - line[-2]).normalized()

	vertices[0] -= start_direction * half_width
	vertices[1] -= start_direction * half_width

	vertices[-2] += end_direction * half_width
	vertices[-1] += end_direction * half_width

	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)

	for i in range(0, vertices.size() - 2, 2):
		var a := vertices[i]
		var b := vertices[i + 1]
		var c := vertices[i + 2]
		var d := vertices[i + 3]

		mesh.surface_add_vertex(Vector3(a.x, 0.0, a.y))
		mesh.surface_add_vertex(Vector3(b.x, 0.0, b.y))
		mesh.surface_add_vertex(Vector3(c.x, 0.0, c.y))

		mesh.surface_add_vertex(Vector3(b.x, 0.0, b.y))
		mesh.surface_add_vertex(Vector3(d.x, 0.0, d.y))
		mesh.surface_add_vertex(Vector3(c.x, 0.0, c.y))

	mesh.surface_end()

func update_shader_parameters() -> void:
	if not material_override:
		return;

	assert(line.size() <= MAX_VERTICES, "Polygon cannot have more than %d vertices." % MAX_VERTICES)

	for i in line.size():
		line_uniform[i] = line[i]

	material_override.set_shader_parameter("line", line_uniform)
	material_override.set_shader_parameter("line_size", line.size())
	material_override.set_shader_parameter("line_width", width)
	
func set_paint_offset(offset: Vector2):
	material_override.set_shader_parameter("paint_offset", offset)
	
func set_paint_color(color: Color):
	material_override.set_shader_parameter("paint_color", color)
