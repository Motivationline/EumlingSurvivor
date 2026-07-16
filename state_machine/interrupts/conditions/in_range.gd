@tool
## Checks whether the Player is in Range, returning true if it is
class_name InRangeToPlayerInterruptCondition extends InterruptCondition

## How far away should we search for the player, inclusive
@export var distance: float = 10


func evaluate() -> bool:
	if not parent or not parent.is_inside_tree(): return false
	if not Player.player or not Player.player.is_inside_tree(): return false
	prints(parent.global_position.distance_to(Player.player.global_position), distance)
	return parent.global_position.distance_to(Player.player.global_position) <= distance
