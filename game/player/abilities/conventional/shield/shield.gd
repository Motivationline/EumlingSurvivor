class_name Shield
extends StaticBody3D
## Protects the entity from projectiles.

## The amount of projectiles the shield can destroy before being deactivated.
@export var max_hits: Array[int] = []
## When true the shield is deactivated at the start.
@export var disabled: bool = true

@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var current_max_hits: int = 0
var current_hits: int = 0


func _ready() -> void:
	if disabled:
		deactivate()
	else:
		activate()


func activate() -> void:
	current_hits = 0
	current_max_hits = max_hits[clampi(Data.game_data.get_eumling_amount(Enum.EUMLING_TYPE.CONVENTIONAL), 0, max_hits.size() - 1)]
	visible = true
	collision_shape.disabled = false
	process_mode = Node.PROCESS_MODE_INHERIT


func deactivate() -> void:
	visible = false
	collision_shape.disabled = true
	process_mode = Node.PROCESS_MODE_DISABLED


func hit() -> void:
	current_hits += 1
	if current_hits >= current_max_hits:
		deactivate()
