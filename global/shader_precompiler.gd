extends Node3D

var registry: Dictionary[PackedScene, bool]

func register(_scene: PackedScene):
	if registry.has(_scene):
		return

	registry.set(_scene, true)
	add_child(_scene.instantiate())
	
func flush(): # we might need to flush the nodes from memory at some point... but when?
	for node in get_children():
		node.queue_free()
