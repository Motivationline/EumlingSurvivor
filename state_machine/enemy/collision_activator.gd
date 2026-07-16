@tool
extends State

## Enables/Disables a node in the tree through process mode
class_name CollisionActivatorState

@export var enable: Array[CollisionShape3D]
@export var disable: Array[CollisionShape3D]


func enter() -> void:
	super()
	for node in enable:
		if node:
			node.process_mode = Node.PROCESS_MODE_INHERIT
			node.disabled = false
	for node in disable:
		if node:
			node.process_mode = Node.PROCESS_MODE_DISABLED
			node.disabled = true

func process(_delta: float) -> State:
	return return_next()
