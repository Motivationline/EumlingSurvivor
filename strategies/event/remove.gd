extends EventStrategy
class_name RemoveEventStrategy

func execute():
	parent.queue_free()
