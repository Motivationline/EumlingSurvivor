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
	pass

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
	return warnings
