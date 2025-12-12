extends ProjectileMovementStrategy
## Adds the given uprgades to the projectile
class_name SpeedFromPlayerProjectileMovementStrategy

var player_speed: float = 0.0

func apply_movement(_delta: float, _current_lifetime: float, _total_lifetime: float):
	if (parent.velocity.is_zero_approx()): parent.velocity = - parent.transform.basis.z
	var speed = parent.velocity.length() + player_speed
	parent.velocity = parent.velocity.normalized() * speed
