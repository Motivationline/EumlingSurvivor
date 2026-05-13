@tool
## Chooses a different state based on an value on the selected node_to_check
class_name DecideValueState extends DeciderState

## The node_to_check to check the value on
@export var node_to_check: Node:
	set(value):
		node_to_check = value
		update_configuration_warnings()
## The name of the value to check for
@export var property_name: String = "":
	set(value):
		property_name = value
		update_configuration_warnings()

## An array of conditions to check against. Will check in order and return the first one that fits.  
## [b]If nothing fits, falls back to "Fallback State"[/b]
@export var checks: Dictionary[DecideValueCheck, State] = {}:
	set(value):
		checks = value
		update_configuration_warnings()

@export var fallback_state: State:
	set(value):
		fallback_state = value
		update_configuration_warnings()

var found: bool = false

func enter() -> void:
	super ()
	found = false
	var value = node_to_check.get(property_name)
	if value == null: return
	for value_check in checks.keys():
		if value_check and value_check.check(value):
			var state = checks.get(value_check)
			if state:
				next_state = state
				found = true
				break
	if not found:
		next_state = fallback_state
		found = true


func process(_delta):
	if found:
		return return_next()

func get_possible_next_states() -> Array[State]:
	var result: Array[State] = [fallback_state]
	result.append_array(checks.values())
	return result

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not node_to_check:
		warnings.append("You need a node to check")
	if not property_name:
		warnings.append("You need the property name")
	if not fallback_state:
		warnings.append("You need a fallback state")
	if fallback_state == self:
		warnings.append("The fallback state for this one really shouldn't be itself.")
	if next_state:
		warnings.append("You've set a next state. This node will never use this configured next state.")

	var keys = checks.keys()
	var missing_states: Array[int] = []
	for index in keys.size():
		var key = keys[index]
		if not key:
			warnings.append("You've got an empty check in your list. That won't do anything.")
		var state = checks.get(key)
		if not state:
			missing_states.append(index + 1)
	if missing_states.size() > 0:
		warnings.append("You're missing the states to the following checks: " + str(missing_states))
	return warnings
