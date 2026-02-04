extends EventStrategy
## Deactivates the Strategies inside the given Array
class_name DeactivateEventStrategy

## Add Deactivation Strategy pool inside this Array
@export var strategies_to_deactivate: Array[Strategy]

## trigger the action after a given delay
@export var is_delayed: bool = false
## after delay time has passed, the action is triggered
@export var delay: float = 0

func execute_event(_data):
	if is_delayed and is_inside_tree():
		await get_tree().create_timer(delay).timeout
	
	for n in strategies_to_deactivate:
		n.is_active = false
