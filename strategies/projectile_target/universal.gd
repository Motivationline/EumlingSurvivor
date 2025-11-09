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
			pass
		TARGET_PROPERTIES.NEW:
			pass
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
			print(targets)
			targets = targets.slice(len(targets)-1, 0, -1)
			print(targets)
		TARGET_SORTERS.STRONGEST:
			pass
		TARGET_SORTERS.WEAKEST:
			pass
	
	# check if the targets are in the given min-/max-radius range, remove others
	for target in targets:
		var dist = parent.global_transform.origin.distance_squared_to(target.global_transform.origin)
		if dist > max_radius or dist < min_radius:
			var i = targets.find(target)
			targets.pop_at(i)
	
	# remove everything thats over the max_targets count
	if len(targets) > max_targets:
		targets = targets.slice(0, max_targets)
	#print("slicing targets", targets)
	
	return targets
