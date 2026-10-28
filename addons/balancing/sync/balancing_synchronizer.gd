@tool
class_name BalancingSynchronizer
extends RefCounted

var _dry_run: bool
var _current_scene: BalancingSceneDescriptor
var _context := BalancingContext.new()
var _error_state := BalancingErrorState.new(_context)


func _init(dry_run: bool) -> void:
	_dry_run = dry_run


func run() -> void:
	var json_parser := BalancingJsonParser.new(_error_state)

	var file: String = json_parser.read_json_file()
	if _error_state.has_error:
		return

	var json: Variant = json_parser.parse_json(file)
	if _error_state.has_error:
		return

	for i: int in range(json.enemy_values.size()):
		_context.set_entry(i)

		var entry: BalancingEntry = json_parser.parse_entry(json.enemy_values[i])
		if _error_state.has_error:
			break

		await _assign_current_scene(entry.scene)
		if _error_state.has_error:
			break

		_context.set_entry(i, entry.scene, entry.difficulty)
		_context.set_target("root")

		_sync_target(_current_scene.root_node, entry.values)
		if _error_state.has_error:
			break

		_sync_children(entry.children)
		if _error_state.has_error:
			break

	if _current_scene:
		_context.set_scene(_current_scene.name)
		_current_scene.close(not _dry_run and not _error_state.has_error)
		_current_scene = null


func _assign_current_scene(scene_name: String) -> void:
	if _current_scene != null and scene_name == _current_scene.name:
		return

	if _current_scene != null:
		_context.set_scene(_current_scene.name)
		_current_scene.close(not _dry_run and not _error_state.has_error)
		_current_scene = null
		await _idle_frame_for_console_output()
	if _error_state.has_error:
		return

	_context.set_scene(scene_name)
	_current_scene = BalancingSceneDescriptor.new(scene_name, _error_state)


func _idle_frame_for_console_output() -> void:
	var scene_tree := Engine.get_main_loop() as SceneTree
	if scene_tree != null:
		await scene_tree.process_frame


func _sync_children(children: Dictionary) -> void:
	for child_name: String in children:
		_context.set_target(child_name)

		if children[child_name] is not Dictionary:
			_error_state.set_error("Target values are not a Dictionary")
			return

		var child_node: Node = _current_scene.root_node.find_child(child_name, true, false)
		if child_node == null:
			_error_state.set_error("Target node was not found")
			return

		_sync_target(child_node, children[child_name])
		if _error_state.has_error:
			return


func _sync_target(target_node: Node, values: Dictionary) -> void:
	var scaler: DifficultyScaler = _get_difficulty_scaler(target_node)
	if _error_state.has_error:
		return

	var overrides: Array[AdjustAttributesElement] = _get_overrides(scaler)
	if _error_state.has_error:
		return

	var existing_overrides: Dictionary[String, AdjustAttributesElement] = {}
	for override: AdjustAttributesElement in overrides.duplicate():
		var attribute: String = override.attribute
		_context.set_attribute(attribute)

		if values.has(attribute):
			if existing_overrides.has(attribute):
				_error_state.set_error("Duplicate override")
				return
			existing_overrides[attribute] = override
		else:
			_delete_override(overrides, override)

	for attribute: String in values:
		_context.set_attribute(attribute)

		if attribute not in target_node:
			_error_state.set_error("Property does not exist on target")
			return

		var base_value: Variant = target_node.get(attribute)
		var desired_value: Variant = _convert_value(values[attribute], base_value)
		if _error_state.has_error:
			return

		var existing_override: AdjustAttributesElement = existing_overrides.get(attribute)

		if base_value == desired_value:
			if existing_override != null:
				_delete_override(overrides, existing_override)
		elif existing_override == null:
			_create_override(overrides, desired_value)
		elif existing_override.value != desired_value:
			_update_override(existing_override, desired_value)


func _get_difficulty_scaler(node: Node) -> DifficultyScaler:
	var key: String = "difficulty_scaler"
	if key not in node:
		_error_state.set_error("Missing '%s' property" % key)
		return

	var property: Variant = node.get(key)
	if property is not DifficultyScaler:
		_error_state.set_error("'%s' is not a DifficultyScaler" % key)
		return

	return property


func _get_overrides(scaler: DifficultyScaler) -> Array[AdjustAttributesElement]:
	var difficulty_level: String = BalancingConfig.DIFFICULTY_PROPERTIES[_context.difficulty]
	if difficulty_level not in scaler:
		_error_state.set_error("Difficulty %s does not exist in DifficultyScaler" % difficulty_level)
		return []

	var values: Variant = scaler.get(difficulty_level)
	if values is not Array[AdjustAttributesElement]:
		_error_state.set_error("Overrides of %s are not an Array[AdjustAttributesElement]" % difficulty_level)
		return []

	return values


func _convert_value(value: Variant, base_value: Variant) -> Variant:
	if typeof(value) == typeof(base_value):
		return value

	if base_value is float and value is int:
		return float(value)

	if base_value is int and value is float and step_decimals(value) == 0:
		return int(value)

	if base_value is StringName and value is String:
		return StringName(value)

	var parameters: Array[String] = [type_string(typeof(value)), type_string(typeof(base_value))]
	_error_state.set_error("Value cannot be converted from %s to %s" % parameters)
	return null


func _delete_override(overrides: Array[AdjustAttributesElement], override: AdjustAttributesElement) -> void:
	_print_change("DELETE")

	if not _dry_run:
		overrides.erase(override)
		_current_scene.changed = true


func _create_override(overrides: Array[AdjustAttributesElement], value: Variant) -> void:
	_print_change("CREATE", value)

	if not _dry_run:
		var new_override := AdjustAttributesElement.new()
		new_override.resource_local_to_scene = true
		new_override.attribute = _context.attribute
		new_override.value = value

		overrides.append(new_override)
		_current_scene.changed = true


func _update_override(override: AdjustAttributesElement, value: Variant) -> void:
	_print_change("UPDATE", value)

	if not _dry_run:
		override.value = value
		_current_scene.changed = true


func _print_change(action: String, value: Variant = null) -> void:
	var parameters: Array[Variant] = [_context.scene, _context.target, _context.difficulty, action, _context.attribute]
	var message: String = "%s | %s | difficulty %d | %s %s" % parameters
	if action != "DELETE":
		message += " = %s" % str(value)
	print("Balancing %s: %s." % ["Dry Run" if _dry_run else "Sync", message])
