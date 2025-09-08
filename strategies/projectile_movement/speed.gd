extends ProjectileMovementStrategy
class_name SpeedProjectileMovementStrategy

@export var speed_over_lifetime: Curve

func apply_movement(_delta: float, _lifetime: float):
	var current_speed = speed_over_lifetime.sample(_lifetime)
	parent.velocity += - parent.transform.basis.z * current_speed
