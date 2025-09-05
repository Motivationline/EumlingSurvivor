extends ProjectileMovementStrategy
class_name SpeedProjectileMovementStrategy

@export var speed_over_lifetime: Curve

func apply_movement(_projectile: Projectile, _lifetime: float):
	var current_speed = speed_over_lifetime.sample(_lifetime)
	_projectile.velocity += - _projectile.transform.basis.z * current_speed