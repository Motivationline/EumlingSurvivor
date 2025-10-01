@abstract
extends Strategy
## Base class for target strategies. [color=red]Do not add, doesn't do anything.[/color]
class_name ProjectileTargetStrategy

var targets: Array[Node]

var hits: Array[Node]

func find_target() -> void: pass
