extends ProjectileMovementStrategy
## Adds the given uprgades to the projectile
class_name SpeedUpgradesProjectileMovementStrategy

var upgrades: Array[Upgrade] = []

func apply_movement(_delta: float, _current_lifetime: float, _total_lifetime: float):
	if (parent.velocity.is_zero_approx()): parent.velocity = - parent.transform.basis.z
	var speed = parent.velocity.length()
	for upgrade in upgrades:
		speed = upgrade.apply(speed)
	parent.velocity = parent.velocity.normalized() * speed
