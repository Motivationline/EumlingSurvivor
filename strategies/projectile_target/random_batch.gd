extends ProjectileTargetStrategy
## sets the target to the closest enemy
class_name TargetRandomBatchProjectileTargetStrategy

@export var amount: int = 3

func find_target():
	var enemies = get_tree().get_nodes_in_group("Enemy")
	if enemies.is_empty():
		return []

	var pick_count = min(amount, enemies.size())

	while parent.targets.size() < pick_count:
		var enemy = enemies[randi_range(0, enemies.size() - 1)]
		if not enemy in parent.targets:
			parent.targets.append(enemy)

	_sort_targets_by_distance()
	
func _sort_targets_by_distance():
	parent.targets.sort_custom(_sort_by_distance)
	
func _sort_by_distance(a: Node, b: Node) -> bool:
	var dist_a = parent.global_transform.origin.distance_to(a.global_transform.origin)
	var dist_b = parent.global_transform.origin.distance_to(b.global_transform.origin)
	return dist_a < dist_b
