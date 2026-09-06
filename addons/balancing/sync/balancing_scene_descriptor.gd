@tool
class_name BalancingSceneDescriptor
extends RefCounted

var name: String
var path: String
var root_node: Node
var packed_scene: PackedScene
var changed: bool = false

var _error_state: BalancingErrorState


func _init(scene_name: String, error_state: BalancingErrorState) -> void:
	_error_state = error_state

	name = scene_name
	path = _find_scene_path(BalancingConfig.SCENE_SEARCH_ROOT)
	if _error_state.has_error:
		return
	if path.is_empty():
		_error_state.set_error("Scene was not found in %s or its subdirectories" % BalancingConfig.SCENE_SEARCH_ROOT)
		return
	if path in EditorInterface.get_open_scenes():
		_error_state.set_error("Scene is currently open in the Editor. Close it before synchronizing")
		return

	var loaded_resource: Resource = ResourceLoader.load(path, "PackedScene", ResourceLoader.CACHE_MODE_IGNORE_DEEP)
	if not loaded_resource:
		_error_state.set_error("Could not load the resource located at %s" % path)
		return
	if loaded_resource is not PackedScene:
		_error_state.set_error("%s is not a PackedScene" % path)
		return
	packed_scene = loaded_resource

	root_node = packed_scene.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	if not root_node:
		_error_state.set_error("Could not instantiate scene")


func close(save_changes: bool) -> void:
	if root_node == null:
		return

	if save_changes and changed:
		_save()

	if root_node != null:
		root_node.free()
		root_node = null


func _save() -> void:
	var error: Error = packed_scene.pack(root_node)
	if error:
		_error_state.set_error("Packing scene failed with error %s" % error_string(error))
		return

	error = ResourceSaver.save(packed_scene, path)
	if error:
		_error_state.set_error("Saving scene failed with error %s" % error_string(error))
		return

	EditorInterface.get_resource_filesystem().update_file(path)


func _find_scene_path(directory_name: String) -> String:
	var found: String = ""

	var directory: DirAccess = DirAccess.open(directory_name)
	var error: Error = DirAccess.get_open_error()
	if error:
		_error_state.set_error("Failed to open directory %s with error %s" % [directory_name, error_string(error)])
		return ""

	error = directory.list_dir_begin()
	if error:
		_error_state.set_error("Failed to initialize directory stream for %s with error %s" % [directory_name, error_string(error)])
		return ""

	var entry: String = directory.get_next()
	while not entry.is_empty() and found.is_empty():
		if entry.begins_with("."):
			entry = directory.get_next()
			continue

		var current_path: String = directory_name.path_join(entry)
		if directory.current_is_dir():
			found = _find_scene_path(current_path)
			if _error_state.has_error:
				break
		elif entry == name:
			found = current_path

		entry = directory.get_next()

	directory.list_dir_end()
	return found
