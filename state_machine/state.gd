@tool
@abstract
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

## If the enemy has a resource, how much of that resource this state costs.
## Depending on the state, this will get consumed at different points (or not at all if we didn't implement it yet)
@export var resource_cost: float = 0.0
signal consumed_resource(amount: float)
var consume_resource_on_enter: bool = false

## Set up a trigger for your animation transition here and it will get triggered when this state starts.
@export var animation_trigger: String

var parent: Enemy
var anim_player: AnimationTree

## Called once when the state machine is first initialized 
func setup(_parent: Enemy, _animation: AnimationTree) -> void:
	parent = _parent
	anim_player = _animation

## Called every time the state is set to be the active state
func enter() -> void:
	if (anim_player && animation_trigger): anim_player.set("parameters/conditions/" + animation_trigger, true)
	if consume_resource_on_enter: consume_resource()
	pass

## Called every time the state is no longer the active state
func exit() -> void:
	if (anim_player && animation_trigger): anim_player.set("parameters/conditions/" + animation_trigger, false)
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
	if (next_state == self): warnings.append("The next state has been set to this node, which will lead to an infinite loop of this state meaning it will never end.\nThis is supported, so all good if it's intended.")
	return warnings

func get_possible_next_states() -> Array[State]:
	return [next_state]

func consume_resource():
	consumed_resource.emit(resource_cost)
