extends ProjectileMovementStrategy
## Controls the projectiles speed over its lifetime
class_name SpeedProjectileMovementStrategy

## Ignores the max_domain of the curve and assumes it describes the entire lifetime.
@export var normalize_to_lifetime: bool = true
## in m/s
@export var speed: Curve

func apply_movement(_delta: float, _current_lifetime: float, _total_lifetime: float):
	if(!speed): return
	var sample_point = (_current_lifetime / _total_lifetime) * speed.max_domain if (normalize_to_lifetime) else fmod(_current_lifetime, speed.max_domain)
	var current_speed = speed.sample(sample_point)
	parent.velocity += - parent.transform.basis.z * current_speed
