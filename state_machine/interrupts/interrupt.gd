@icon("interrupt.svg")
@tool
class_name Interrupt extends Node

## The state to switch to if the interrupt condition evaluates to true.  
## Goes to the states default next_state if empty.
@export var state_to_go_to: State

## The condition to evaluate. If empty, will never trigger.
@export var condition: InterruptCondition:
	set(value):
		condition = value
		update_configuration_warnings()

func setup(_parent: StateMachinePoweredEntity):
	if condition:
		condition.setup(_parent)

func start():
	if condition:
		condition.start()

func evaluate():
	if condition:
		return condition.evaluate()
	return false

func _get_configuration_warnings() -> PackedStringArray:
	if not condition:
		return ["No condition is set. This interrupt will never trigger."]
	return []
