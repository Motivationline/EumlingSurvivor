@icon("strategy.svg")
@abstract
extends Node
## Base class for all strategies. [color=red]Do not add, doesn't do anything.[/color]
class_name Strategy

@export var isActive: bool = true

var parent: CharacterBody3D

## Adds all functionality that needs to be set up for this strategy to function properly
func _setup(_parent: Node, _owner: Node) -> void:
	parent = _parent

## Helper function to set up all strategies in an array
static func _setup_array(_arr: Array, _parent: Node, _owner: Node):
	for s in _arr:
		if (s && s is Strategy): s._setup(_parent, _owner)
