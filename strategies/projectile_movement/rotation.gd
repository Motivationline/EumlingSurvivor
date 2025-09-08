extends ProjectileMovementStrategy
class_name RotationProjectileMovementStrategy

## In degrees
@export var rotation_over_lifetime: Curve

var start_rotation: float

func _setup(_attached_to: Node):
	super._setup(_attached_to)
	start_rotation = (_attached_to as Node3D).rotation_degrees.y


func apply_movement(_delta: float , _lifetime: float):
	var current_rotation = rotation_over_lifetime.sample(_lifetime)
	parent.rotation_degrees.y = current_rotation + start_rotation
