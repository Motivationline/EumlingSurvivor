extends TargetStrategy
class_name ClosestEntityTargetStrategy

@export_enum("Enemy", "Player") var group: String

func get_target_position(_parent: Node3D) -> Vector3:
	var closest = get_closest_entity(_parent)
	if (!closest): return super (_parent) # Fallback to default
	return closest.global_position

func get_closest_entity(_parent) -> Node3D:
	var nodes = _parent.get_tree().get_nodes_in_group(group)
	var min_distance: float = INF
	var found_node: Node3D
	for node in nodes:
		if (node == _parent): continue
		if (node is Node3D):
			var distance = node.global_position.distance_squared_to(_parent.global_position)
			if (distance < min_distance):
				found_node = node
				min_distance = distance
	return found_node
