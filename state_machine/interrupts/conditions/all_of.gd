@tool
## Evaluates all given conditions and only returns true, if they all return true (basically a logical AND)
class_name AllOfInterruptCondition extends InterruptCondition

@export var conditions: Array[InterruptCondition]:
	set(value):
		conditions = value
		update_configuration_warnings()

func start():
	for condition in conditions:
		if condition and condition != self: condition.start()

func evaluate() -> bool:
	for condition in conditions:
		if condition and condition != self and not condition.evaluate():
			return false
	
	return true

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if conditions.is_empty():
		warnings.push_back("No condition is set. This will always evaluate to true.")
	else:
		var found_a_condition: bool = false
		for i in conditions.size():
			var c = conditions[i]
			if not c:
				warnings.push_back("No condition in array at position %s. Check your conditions." % [i])
			else:
				found_a_condition = true
				if c == self:
					warnings.push_back("You shouldn't have this state in the list of states to be evaluated. It will be ignored.")
		if not found_a_condition:
			warnings.push_back("All elements in the array are null! This will always evaluate to true.")


	return warnings
