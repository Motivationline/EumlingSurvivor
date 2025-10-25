extends EventStrategy
## Removes the node when event is called
class_name DestroyNodeEventStrategy

## Add Node pool inside this Array
@export var nodes: Array[Node]:
	set(new_value):
		nodes = new_value

func event_triggered(_data):
	for n in nodes:
		n.queue_free()
