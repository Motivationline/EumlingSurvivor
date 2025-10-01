extends EventStrategy
## Removes the node when event is called
class_name SetTargetsEventStrategy

func event_triggered(_data):
	parent._set_targets()
