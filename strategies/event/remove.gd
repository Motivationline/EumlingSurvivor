extends EventStrategy
## Removes the node when event is called
class_name RemoveEventStrategy

func event_triggered(_data):
	parent.queue_free()
