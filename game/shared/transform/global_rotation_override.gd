extends Node3D

@export var global_rotation_override: Vector3

func _process(delta: float) -> void:
	global_rotation = global_rotation_override * (PI / 180.0)
