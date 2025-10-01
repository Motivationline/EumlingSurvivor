extends EventStrategy
## Removes the node when event is called
class_name ClearTargetsEventStrategy


func event_triggered(_data):
	for t in parent.targeting:
		if t.isActive:
			t.targets.clear()
