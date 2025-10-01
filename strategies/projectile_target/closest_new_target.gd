extends ProjectileTargetStrategy
## sets the target to the closest enemy
class_name TargetClosestNewProjectileTargetStrategy

func find_target():
	var enemies = get_tree().get_nodes_in_group("Enemy")
	get_closest_Node(enemies)

# returns the closest Node from the given Array 
func get_closest_Node(_nodes: Array[Node]):
	var closest: Node3D = null
	var closest_dist = INF
	var enemies: Array[Node] = _nodes
	for n: Node3D in enemies:
		var dist = parent.global_position.distance_to(n.global_position)
		if dist < closest_dist && not(hits.has(n)):
			closest_dist = dist
			closest = n
	targets.append(closest)#adds the closest to the targets array
