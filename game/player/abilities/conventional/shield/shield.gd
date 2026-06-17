class_name Shield
extends StaticBody3D
## Protects the entity from projectiles.

## The amount of projectiles the shield can destroy before being deactivated.
@export var max_hits: int = 1
## When true the shield is deactivated at the start.
@export var disabled: bool = true

@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var current_hits: int = 0


func _ready() -> void:
	if disabled:
		deactivate()
	else:
		activate()


func activate() -> void:
	current_hits = 0
	visible = true
	collision_shape.disabled = false
	process_mode = Node.PROCESS_MODE_INHERIT


func deactivate() -> void:
	visible = false
	collision_shape.disabled = true
	process_mode = Node.PROCESS_MODE_DISABLED


func hit() -> void:
	current_hits += 1
	if current_hits >= max_hits:
		deactivate()
