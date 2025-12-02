extends EventStrategy
## Clears the targets Array
class_name ClearTargetsEventStrategy


func event_triggered(_data):
	parent.clear_targets()
