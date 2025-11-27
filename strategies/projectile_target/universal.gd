extends ProjectileTargetStrategy
## sets the target(s) based on inputs
class_name UniversalTargetingProjectileTargetStrategy

enum TARGET_TYPES { PLAYER, ENEMY, LEVEL }
enum TARGET_PROPERTIES {HIT, NEW, BOTH}
enum TARGET_SORTERS {ARBITRARY, RANDOM, CLOSEST, FARTHEST, STRONGEST, WEAKEST}

## preferred type of entety or Node you want to target
@export var target_type: TARGET_TYPES
## preferred target property the target needs to have
@export var target_property: TARGET_PROPERTIES
## preferred sorting of targets
@export var target_sorter: TARGET_SORTERS
## the max distance in that we pick targets from
@export_range(0,100,0.1) var max_radius: float
## the min distance in that we pick targets from
@export_range(0,100,0.1) var min_radius: float
## preferred maximum target amount
@export var max_targets: int


func find_target():
	#print("finding targets")
	var targets: Array[Node]
	
	match target_type:
		TARGET_TYPES.PLAYER:
			targets = get_tree().get_nodes_in_group("Player")
		TARGET_TYPES.ENEMY:
			targets = get_tree().get_nodes_in_group("Enemy")
		TARGET_TYPES.LEVEL:
			targets = get_tree().get_nodes_in_group("Level")
		#get_closest_Node(targets)
		#print("getting all targets", targets)
	
	match target_property:
		TARGET_PROPERTIES.HIT:
			targets = targets.filter(parent.hits)
		TARGET_PROPERTIES.NEW:
			targets = targets.filter(func(target):
				return target not in parent.hits
			)
		TARGET_PROPERTIES.BOTH:
			pass
	
	match target_sorter:
		TARGET_SORTERS.ARBITRARY:
			pass
		TARGET_SORTERS.RANDOM:
			targets.shuffle()
		TARGET_SORTERS.CLOSEST:
			targets = Utils.sort_array_by_distance(targets, parent)
		TARGET_SORTERS.FARTHEST:
			targets = Utils.sort_array_by_distance(targets, parent)
			targets = targets.slice(len(targets)-1, 0, -1)
		TARGET_SORTERS.STRONGEST:
			targets.sort_custom(sort_by_strength)
		TARGET_SORTERS.WEAKEST:
			targets.sort_custom(sort_by_strength)
			targets.reverse()
	
	# check if the targets are in the given min-/max-radius range, remove others
	targets = targets.filter(func(target): 
		var dist = parent.global_transform.origin.distance_to(target.global_transform.origin)
		return dist < max_radius and dist > min_radius
	)
	
	# remove everything thats over the max_targets count
	if len(targets) > max_targets:
		targets = targets.slice(0, max_targets)
	#print("slicing targets", targets)
	return targets

static func sort_by_strength(a: Node, b: Node) -> bool:
	var health_a = a.health
	var health_b = b.health
	return health_a < health_b
