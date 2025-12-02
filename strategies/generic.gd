@icon("strategy.svg")
@abstract
extends Node
## Base class for all strategies. [color=red]Do not add, doesn't do anything.[/color]
class_name Strategy

@export var is_active: bool = true:
	set(new_value):
		is_active = new_value
		if not is_active:
			self.set_process(false)
		else:
			self.set_process(true)

var parent: CharacterBody3D
var owning_entity: Node3D

## Adds all functionality that needs to be set up for this strategy to function properly
func _setup(_parent: CharacterBody3D, _owner: Node3D) -> void:
	parent = _parent
	owning_entity = _owner

## Helper function to set up all strategies in an array
static func _setup_array(_arr: Array, _parent: CharacterBody3D, _owner: Node3D):
	for s in _arr:
		if (s && s is Strategy): s._setup(_parent, _owner)
