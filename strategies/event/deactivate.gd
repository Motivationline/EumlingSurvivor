extends EventStrategy
## Removes the node when event is called
class_name DeactivateEventStrategy

## Add Node pool inside this Array
@export var strats: Array[Node]:
	set(new_value):
		strats = new_value

func event_triggered(_data):
	for n in strats:
		#n.hide()
		n.is_active = false
		set_process(false)
