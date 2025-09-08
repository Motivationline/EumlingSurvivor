extends Node
class_name Strategy

var parent: CharacterBody3D

## Adds all functionality that needs to be set up for this strategy to function properly
func _setup(_parent: Node) -> void:
	parent = _parent

static func _setup_array(_arr: Array, _parent: Node):
	for s in _arr:
		if (s && s is Strategy): s._setup(_parent)
