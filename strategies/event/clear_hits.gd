extends EventStrategy
## Removes the node when event is called
class_name ClearHitsEventStrategy

func event_triggered(_data):
	parent.hits.clear()
