@tool
class_name MeshPolygon3D extends MeshInstance3D

const MAX_VERTICES := 32

@export
var polygon: PackedVector2Array = PackedVector2Array([Vector2(-0.5, -0.5), Vector2(0.5, -0.5), Vector2(0.75, 0.25), Vector2(0.0, 0.75), Vector2(-0.75, 0.25)]):
	set(value):
		polygon = value
		mesh = create_polygon_mesh_3d(polygon)
		update_shader_parameters()

var polygon_uniform: PackedVector2Array

func _init() -> void:
	polygon_uniform = PackedVector2Array()
	polygon_uniform.resize(MAX_VERTICES)

func _notification(what: int) -> void:
	if what == NOTIFICATION_EDITOR_PRE_SAVE:
		mesh = null
	elif what == NOTIFICATION_EDITOR_POST_SAVE:
		mesh = create_polygon_mesh_3d(polygon)

func update_shader_parameters() -> void:
	assert(polygon.size() <= MAX_VERTICES, "Polygon cannot have more than %d vertices." % MAX_VERTICES)
	for i in polygon.size():
		polygon_uniform[i] = polygon[i]
		
	if not material_override:
		return;
		
	material_override.set_shader_parameter("polygon", polygon_uniform)
	material_override.set_shader_parameter("polygon_size", polygon.size())

func set_paint_offset(offset: Vector2):
	material_override.set_shader_parameter("paint_offset", offset)
	
func get_paint_color() -> Color:
	return material_override.get_shader_parameter("paint_color")

static func create_polygon_mesh_3d(points: PackedVector2Array) -> ArrayMesh:
	var indices: PackedInt32Array = Geometry2D.triangulate_polygon(points)
	
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var tangents := PackedFloat32Array()

	for p in points:
		vertices.append(Vector3(p.x, 0.0, p.y))
		normals.append(Vector3.UP)
		uvs.append(p)
		tangents.append_array([1.0, 0.0, 0.0, 1.0])
	
	var surface_array := []
	surface_array.resize(Mesh.ARRAY_MAX)
	surface_array[Mesh.ARRAY_VERTEX] = vertices
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_TANGENT] = tangents
	surface_array[Mesh.ARRAY_INDEX] = indices
	
	var arr_mesh := ArrayMesh.new()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	return arr_mesh

static func enlarge_polygon(polygon: PackedVector2Array, offset: float) -> PackedVector2Array:
	var centroid := Vector2.ZERO
	for point in polygon:
		centroid += point
	centroid /= polygon.size()

	var enlarged := PackedVector2Array()
	for point in polygon:
		var direction = (point - centroid).normalized()
		enlarged.append(point + direction * offset)

	return enlarged
