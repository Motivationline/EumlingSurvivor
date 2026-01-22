extends EventStrategy
## Activates the given Strategies from the Array
class_name ActivateEventStrategy

## Add Activation Strategy pool inside this Array
@export var strategies_to_activate: Array[Strategy]

## trigger the action after a given delay
@export var is_delayed: bool = false
## after delay time has passed, the action is triggered
@export var delay: float = 0

func event_triggered(_data):
	if is_delayed and is_inside_tree():
		await get_tree().create_timer(delay).timeout
	
	for n in strategies_to_activate:
		#n.show()
		n.is_active = true
