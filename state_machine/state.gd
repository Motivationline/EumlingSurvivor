@tool
extends Node
class_name State

## What state should be activated after this one?
@export var next_state: State:
	set(new_value):
		next_state = new_value
		update_configuration_warnings()

## How often should this state run before it activates the Next State
@export var repeat_self: int = 1:
	set(new_value):
		repeat_self = new_value
		update_configuration_warnings()
var current_iteration: int = 0

var parent: CharacterBody3D

func setup(_parent: CharacterBody3D) -> void:
	parent = _parent

func enter() -> void:
	pass

func exit() -> void:
	pass

func process(_delta: float) -> State:
	return null

func physics_process(_delta: float) -> State:
	return null

func return_next() -> State:
	current_iteration += 1
	if (current_iteration >= repeat_self):
		current_iteration = 0
		return next_state
	return self

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if (!next_state): warnings.append("Needs a Next State")
	if (repeat_self <= 0): warnings.append("Repeat self must be 1 or above")
	return warnings
