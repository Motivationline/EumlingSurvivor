extends EventStrategy
## clears the hit array
class_name ClearHitsEventStrategy

func execute_event(_data):
	parent.clear_hits()
