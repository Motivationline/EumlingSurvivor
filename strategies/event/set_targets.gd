extends EventStrategy
## Removes the node when event is called
class_name SetTargetsEventStrategy

func event_triggered(_data):
	#print("setting targets")
	parent._set_targets()
