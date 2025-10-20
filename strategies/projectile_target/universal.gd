extends ProjectileTargetStrategy
## sets the target(s) based on inputs
class_name UniversalTargetingProjectileTargetStrategy

enum target_types { Player, Enemy }

## preferred type of entety or Node you want to target
@export var target_type: target_types
## the max distance in that we pick targets from
@export_range(0,100,0.1) var max_radius: float
## the min distance in that we pick targets from
@export_range(0,100,0.1) var min_radius: float
## preferred maximum target amount
@export var max_targets: int
## preferrde minimum target amount
@export var min_targets: int


func find_target():
	#print("finding targets")
	var targets: Array[Node]
	
	if target_type == target_types.Player:
		pass
	elif target_type == target_types.Enemy:
		targets = get_tree().get_nodes_in_group("Enemy")
		#get_closest_Node(targets)
		#print("getting all targets", targets)
	
	_sort_targets_by_distance(targets)
	
	for target in targets:
		var dist = parent.global_transform.origin.distance_to(target.global_transform.origin)
		if dist > max_radius or dist < min_radius:
			var i = targets.find(target)
			targets.pop_at(i)
	
	if len(targets) < min_targets:
		while len(targets) < min_targets:
			#iterate through enemies and add closest ones if they arent added yet
			pass
	
	if len(targets) > max_targets:
		targets = targets.slice(0, max_targets)
	#print("slicing targets", targets)
	
	parent.targets = targets
	
func _sort_targets_by_distance(_targets):
	_targets.sort_custom(func(a, b): return _sort_by_distance(a, b))
	
func _sort_by_distance(a: Node, b: Node) -> bool:
	var dist_a = parent.global_transform.origin.distance_to(a.global_transform.origin)
	var dist_b = parent.global_transform.origin.distance_to(b.global_transform.origin)
	return dist_a < dist_b

# returns the closest Node from the given Array
func get_closest_Node(_nodes: Array[Node]):
	var closest: Node3D = null
	var closest_dist = INF
	var enemies: Array[Node] = _nodes
	for n: Node3D in enemies:
		var dist = parent.global_position.distance_to(n.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = n
	parent.targets.append(closest)#adds the closest to the targets array
	#print("Targets: ", parent.targets, "len: ", len(parent.targets), "idx_0: ", parent.targets[0])
