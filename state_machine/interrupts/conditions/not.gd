@tool
## Inverts the given Condition (logical NOT)
class_name NotInterruptCondition extends InterruptCondition

@export var condition: InterruptCondition:
	set(value):
		condition = value
		update_configuration_warnings()

func start():
	if condition and condition != self: condition.start()

func evaluate() -> bool:
	if condition and condition != self:
		return not condition.evaluate()
	return false

func _get_configuration_warnings() -> PackedStringArray:
	if not condition:
		return ["No Condition is set. This will always evaluate as false."]
	if condition == self:
		return ["The condition shouldn't be set to itself! Avoid infinite loops!"]
	return []