@tool
extends EventStrategy
## Triggers a State from the State Machine
class_name TriggerStateEventStrategy

@export var state_machine: StateMachine

@export var state_to_execute: State

func _ready() -> void:
	pass

func execute_event(_data):
	#print("switching state")
	state_machine.current_state.exit()
	state_machine.current_state = state_to_execute
	state_machine.current_state.enter()
