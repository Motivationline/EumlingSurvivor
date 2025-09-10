@tool
@icon("state.svg")
extends Node

## [color=red]Do not add to your scene![/color] This is the base class for States and does nothing by itself.
class_name State

## What state should be activated after this one?
@export var next_state: State:
	set(new_value):
		next_state = new_value
		update_configuration_warnings()

## How often should this state run before it activates the [member State.next_state]. Might be ignored if not applicable. Must be 1 or above.
@export var repeat_self: int = 1:
	set(new_value):
		repeat_self = max(new_value, 1)
		update_configuration_warnings()
var current_iteration: int = 0

var parent: CharacterBody3D

## Called once when the state machine is first initialized 
func setup(_parent: CharacterBody3D) -> void:
	parent = _parent

## Called every time the state is set to be the active state
func enter() -> void:
	pass

## Called every time the state is no longer the active state
func exit() -> void:
	pass

## While active, this is called with the parents regular _process() function
func process(_delta: float) -> State:
	return null

## While active, this is called with the parents regular _physics_process() function
func physics_process(_delta: float) -> State:
	return null

## Returns the next state, taking [repeat_self] into account
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
	if (next_state == self): warnings.append("The next state has been set to this node, which will lead to an infinite loop of this state.\nThis is supported, so all good if it's intended.")
	return warnings
