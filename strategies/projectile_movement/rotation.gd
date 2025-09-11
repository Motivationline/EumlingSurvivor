extends ProjectileMovementStrategy
## Sets a projectiles rotation based on its initial rotation over its lifetime
class_name RotationProjectileMovementStrategy

## Ignores the max_domain of the curve and assumes it describes the entire lifetime.
@export var normalize_to_lifetime: bool = true

## In degrees
@export var rotation: Curve


var start_rotation: float

func _setup(_attached_to: Node):
	super._setup(_attached_to)
	start_rotation = (_attached_to as Node3D).rotation_degrees.y


func apply_movement(_delta: float, _current_lifetime: float, _total_lifetime: float):
	if (!rotation): return
	var sample_point = (_current_lifetime / _total_lifetime) * rotation.max_domain if (normalize_to_lifetime) else fmod(_current_lifetime, rotation.max_domain)
	var current_rotation = rotation.sample(sample_point)
	parent.rotation_degrees.y = current_rotation + start_rotation
