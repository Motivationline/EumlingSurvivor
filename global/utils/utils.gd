extends Node

class_name Utils

# returns the closest Node from the given Array 
static func get_closest_node(_origin: Node3D, _targets: Array[Node3D]):
	if len(_targets) > 0:
		var closest: Node3D = null
		var closest_dist = INF
		for n: Node3D in _targets:
			var dist = _origin.distance_squared_to(n.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest = n
		return closest

# get the distance to object somehow
static func sort_array_by_distance(_arr: Array, _origin: Node) -> Array:
	_arr.sort_custom(func(a, b): return sort_by_distance(a, b, _origin))
	return _arr

static func sort_by_distance(a: Node, b: Node, origin: Node) -> bool:
	var dist_a = origin.global_position.distance_squared_to(a.global_transform.origin)
	var dist_b = origin.global_position.distance_squared_to(b.global_transform.origin)
	return dist_a < dist_b
