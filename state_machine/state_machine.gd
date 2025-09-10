@icon("state_machine.svg")
@tool
extends Node

## The controller for [State] Nodes
class_name StateMachine

## The state this state machine starts with initially
@export var initial_state: State:
	set(new_value):
		initial_state = new_value
		update_configuration_warnings()

var current_state: State

var parent: CharacterBody3D

func setup(_parent: CharacterBody3D):
	parent = _parent
	for child in get_children():
		if (child is State):
			child.setup(parent)
	switch_to_state(initial_state)

func _ready():
	child_order_changed.connect(update_configuration_warnings)

func process(delta: float):
	if (current_state): switch_to_state(current_state.process(delta))

func physics_process(delta: float):
	if (current_state): switch_to_state(current_state.physics_process(delta))

func switch_to_state(next_state: State):
	if (!next_state): return

	if (current_state): current_state.exit()

	current_state = next_state
	current_state.enter()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []

	if (!initial_state): warnings.append("Needs an initial state.")
	else:
		var uncalled := _get_uncalled_states()
		if(uncalled.size() > 0):
			var state_list: String = ""
			for state in uncalled:
				state_list += state.name + ", "
			warnings.append("The following states are never reached: %s" % state_list)
	return warnings

func _get_uncalled_states() -> Array[State]:
	var states := _get_all_states(self)
	var next_state = initial_state
	while (states.has(next_state)):
		states.remove_at(states.find(next_state))
		next_state = next_state.next_state
	return states

func _get_all_states(_node: Node) -> Array[State]:
	var states: Array[State] = []
	for child in _node.get_children():
		if child is State:
			states.append(child)
		if (child.get_child_count() > 0):
			states.append_array(_get_all_states(child))
	return states
