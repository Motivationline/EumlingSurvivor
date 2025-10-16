extends ProjectileTargetStrategy
## sets the target(s) based on inputs
class_name UniversalTargetingProjectileTargetStrategy

## preferred type of entety or Node you want to target
@export var target_type: Node
## the max distance in that we pick targets from
@export_range(0,100,1) var max_radius: float
## the min distance in that we pick targets from
@export_range(0,100,1) var min_radius: float
## preferred max target amount
@export var max_targets: float


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
		if dist < closest_dist:
			closest_dist = dist
			closest = n
	parent.targets.append(closest)#adds the closest to the targets array
	print("Targets: ", parent.targets, "len: ", len(parent.targets), "idx_0: ", parent.targets[0])
