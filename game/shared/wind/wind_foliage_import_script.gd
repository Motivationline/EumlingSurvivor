@tool
extends EditorScenePostImport

func _post_import(scene: Node) -> Object:
	var source_file_path: String = get_source_file()
	if source_file_path.is_empty():
		push_warning("Wind foliage import script: source file path is empty.")
		return scene

	var source_dir_path: String = source_file_path.get_base_dir()
	var glb_name: String = source_file_path.get_file().get_basename()
	var shader_path: String = "%s/wind_foliage_shader.gdshader" % get_script().resource_path.get_base_dir()
	var shader: Shader = load(shader_path) as Shader
	if shader == null:
		push_error("Wind foliage import script: failed to load shader at %s" % shader_path)
		return scene

	var material_cache: Dictionary = {}
	var material_counter: int = 0
	_process_node(scene, shader, source_dir_path, glb_name, material_cache, material_counter)
	return scene

func _process_node(node: Node, shader: Shader, source_dir_path: String, glb_name: String, material_cache: Dictionary, material_counter: int) -> int:
	if node is MeshInstance3D and node.mesh:
		var mesh: Mesh = node.mesh
		var aabb_size: Vector3 = mesh.get_aabb().size
		for i in range(mesh.get_surface_count()):
			var src_mat: Material = mesh.surface_get_material(i)
			if src_mat == null and node.material_override:
				src_mat = node.material_override
			if src_mat == null:
				continue;

			var material_key: int = src_mat.get_instance_id()
			var shader_material: ShaderMaterial = material_cache.get(material_key) as ShaderMaterial
			if shader_material == null:
				material_counter += 1
				var save_path: String = "%s/%s_foliage_material_%d.tres" % [source_dir_path, glb_name, material_counter]

				if ResourceLoader.exists(save_path):
					var existing_material: ShaderMaterial = load(save_path) as ShaderMaterial
					if existing_material != null:
						shader_material = existing_material
					else:
						shader_material = ShaderMaterial.new()
				else:
					shader_material = ShaderMaterial.new()

				_refresh_shader_material_properties(shader_material, src_mat, shader, aabb_size)
				var save_error: Error = ResourceSaver.save(shader_material, save_path)
				if save_error != OK:
					push_error("Wind foliage import script: failed to save material at %s (error %s)" % [save_path, save_error])
				else:
					var saved_material: ShaderMaterial = load(save_path) as ShaderMaterial
					if saved_material != null:
						shader_material = saved_material
				material_cache[material_key] = shader_material

			mesh.surface_set_material(i, shader_material)

	for child in node.get_children():
		material_counter = _process_node(child, shader, source_dir_path, glb_name, material_cache, material_counter)

	return material_counter

func _refresh_shader_material_properties(shader_material: ShaderMaterial, src_mat: Material, shader: Shader, size: Vector3) -> void:
	shader_material.shader = shader

	var albedo_texture: Texture2D = null
	var metallic: float = 0.0
	var specular: float = 0.5
	var roughness: float = 1.0

	if src_mat is BaseMaterial3D:
		albedo_texture = src_mat.albedo_texture
		metallic = src_mat.metallic
		specular = src_mat.metallic_specular
		roughness = src_mat.roughness

	shader_material.set_shader_parameter("albedo_texture", albedo_texture)
	shader_material.set_shader_parameter("metallic", metallic)
	shader_material.set_shader_parameter("specular", specular)
	shader_material.set_shader_parameter("roughness", roughness)
	shader_material.set_shader_parameter("size", size)
	
