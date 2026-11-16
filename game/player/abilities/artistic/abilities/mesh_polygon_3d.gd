@tool
class_name MeshPolygon3D extends MeshInstance3D

const MAX_VERTICES := 32

@export
var polygon: PackedVector2Array = PackedVector2Array([Vector2(-0.5, -0.5), Vector2(0.5, -0.5), Vector2(0.75, 0.25), Vector2(0.0, 0.75), Vector2(-0.75, 0.25)]):
	set(value):
		polygon = value
		mesh = create_polygon_mesh_3d(value)
		update_shader_parameters()

var polygon_uniform: PackedVector2Array

func _init() -> void:
	polygon_uniform = PackedVector2Array()
	polygon_uniform.resize(MAX_VERTICES)

func update_shader_parameters() -> void:
	assert(polygon.size() <= MAX_VERTICES, "Polygon cannot have more than %d vertices." % MAX_VERTICES)
	for i in polygon.size():
		polygon_uniform[i] = polygon[i]
		
	if not material_override:
		return;
		
	material_override.set_shader_parameter("polygon", polygon_uniform)
	material_override.set_shader_parameter("polygon_size", polygon.size())
	material_override.set_shader_parameter("paint_offset", Vector2(randf_range(0,10),randf_range(0,10)))

static func create_polygon_mesh_3d(points: PackedVector2Array) -> ArrayMesh:
	var indices: PackedInt32Array = Geometry2D.triangulate_polygon(points)
	
	var vertices := PackedVector3Array()
	
	for p in points:
		vertices.append(Vector3(p.x, 0.0, p.y))
	
	var surface_array := []
	surface_array.resize(Mesh.ARRAY_MAX)
	surface_array[Mesh.ARRAY_VERTEX] = vertices
	surface_array[Mesh.ARRAY_INDEX] = indices
	
	var arr_mesh := ArrayMesh.new()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	return arr_mesh
