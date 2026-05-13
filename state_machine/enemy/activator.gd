@tool
extends State

## Enables/Disables a node in the tree through process mode
class_name ActivatorState

@export var enable: Array[Node]
@export var disable: Array[Node]

func enter() -> void:
	super()
	for node in enable:
		if node:
			node.process_mode = Node.PROCESS_MODE_INHERIT
			node.show()
	for node in disable:
		if node:
			node.process_mode = Node.PROCESS_MODE_DISABLED
			node.hide()

func process(_delta: float) -> State:
	return return_next()
