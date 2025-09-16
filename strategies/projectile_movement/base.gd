@abstract
extends Strategy
## Base class for projectile movement strategies. [color=red]Do not add, doesn't do anything.[/color]
class_name ProjectileMovementStrategy

func apply_movement(_delta: float, _current_lifetime: float, _total_lifetime: float) -> void: pass