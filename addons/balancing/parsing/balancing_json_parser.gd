@tool
class_name BalancingJsonParser
extends RefCounted

var _error_state: BalancingErrorState


func _init(error_state: BalancingErrorState) -> void:
	_error_state = error_state


func read_json_file() -> String:
	var config := BalancingConfig
	var file: String = FileAccess.get_file_as_string(config.JSON_FILE)

	var error: int = FileAccess.get_open_error()
	if error:
		_error_state.set_error("Opening %s failed with error %s" % [config.JSON_FILE, error_string(error)])
		return ""
	if file.is_empty():
		_error_state.set_error("File %s is empty" % [config.JSON_FILE])
		return ""

	return file


func parse_json(file_content: String) -> Variant:
	var config := BalancingConfig
	var json := JSON.new()

	var error: Error = json.parse(file_content)
	if error:
		var parameters: Array[Variant] = [config.JSON_FILE, json.get_error_message(), json.get_error_line()]
		_error_state.set_error("Parsing %s as JSON failed with error %s on line %d" % parameters)
		return
	if json.data is not Dictionary:
		_error_state.set_error("The root node of %s is not a Dictionary" % config.JSON_FILE)
		return
	if "enemy_values" not in json.data:
		_error_state.set_error("Missing 'enemy_values' field in %s" % config.JSON_FILE)
		return
	if json.data.enemy_values is not Array:
		_error_state.set_error("'enemy_values' in %s is not an Array" % config.JSON_FILE)
		return

	return json.data


func parse_entry(entry: Variant) -> BalancingEntry:
	if entry is not Dictionary:
		_error_state.set_error("Entry is not a Dictionary")
		return

	var validated_entry := BalancingEntry.new()

	if "scene" not in entry:
		_error_state.set_error("Missing 'scene' field")
		return
	if entry.scene is not String:
		_error_state.set_error("'scene' is not a String")
		return
	validated_entry.scene = entry.scene

	if "difficulty" not in entry:
		_error_state.set_error("Missing 'difficulty' field")
		return
	if entry.difficulty is not float:
		_error_state.set_error("'difficulty' is not a number")
		return
	if step_decimals(entry.difficulty) != 0:
		_error_state.set_error("'difficulty' is not an integer")
		return
	var difficulty := int(entry.difficulty)
	if difficulty < 0:
		_error_state.set_error("'difficulty' is negative")
		return
	if difficulty >= BalancingConfig.DIFFICULTY_PROPERTIES.size():
		_error_state.set_error("'difficulty' is out of bounds")
		return
	validated_entry.difficulty = difficulty

	if "values" in entry:
		if entry.values is not Dictionary:
			_error_state.set_error("'values' is not a Dictionary")
			return
		validated_entry.values = entry.values

	if "children" in entry:
		if entry.children is not Dictionary:
			_error_state.set_error("'children' is not a Dictionary")
			return
		validated_entry.children = entry.children

	return validated_entry
