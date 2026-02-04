extends EventStrategy
## Removes the node when event is called
class_name RemoveEventStrategy

func execute_event(_data):
	parent.queue_free()
