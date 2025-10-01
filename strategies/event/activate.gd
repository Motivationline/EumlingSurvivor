extends EventStrategy
## Removes the node when event is called
class_name ActivateEventStrategy

## Add Node pool inside this Array
@export var nodes: Array[Node]:
	set(new_value):
		nodes = new_value

func event_triggered(_data):
	for n in nodes:
		#n.show()
		n.is_active = true
