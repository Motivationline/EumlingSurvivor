extends EventStrategy
class_name RemoveEventStrategy

func execute(_data):
	parent.queue_free()
