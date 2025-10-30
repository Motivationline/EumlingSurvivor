@tool
extends EventStrategy
## Triggers a State from the State Machine
class_name TriggerStateEventStrategy

@export var state_to_execute: State

func _ready() -> void:
	pass

func event_triggered(_data):
	#get StateMachine .current_state.exit()
	state_to_execute.enter()
