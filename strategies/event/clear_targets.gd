extends EventStrategy
## Clears the targets Array
class_name ClearTargetsEventStrategy


func execute_event(_data):
	parent.clear_targets()
