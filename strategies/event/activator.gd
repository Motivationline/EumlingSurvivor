extends EventStrategy
## Enables/Disables a node in the tree through process mode
class_name ActivatorEventStrategy

@export var enable: Array[Node]
@export var disable: Array[Node]

func execute_event(_data):
	for node in enable:
		if node:
			node.process_mode = Node.PROCESS_MODE_INHERIT
	for node in disable:
		if node:
			node.process_mode = Node.PROCESS_MODE_DISABLED
