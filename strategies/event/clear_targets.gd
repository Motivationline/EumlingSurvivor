extends EventStrategy
## Removes the node when event is called
class_name ClearTargetsEventStrategy


func event_triggered(_data):
	parent.targets.clear()
