extends EventStrategy
## clears the hit array
class_name ClearHitsEventStrategy

func event_triggered(_data):
	parent.clear_hits()
