extends ProjectileTargetStrategy
## sets the target to the closest enemy
class_name TargetRandomProjectileTargetStrategy

func find_target():
	var enemies = get_tree().get_nodes_in_group("Enemy")
	targets.append(enemies[randi_range(0, len(enemies))])
