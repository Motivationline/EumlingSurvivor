@tool
extends State
## Pick a a point by the given method and tp there
## 
## Ends after teleporting.
class_name TeleportToOnNavMeshState

enum target_types { PLAYER, TEAMMEMBER, RANDOM, BACK }

## How long to wait [b]after[/b] reaching the target location before proceeding to the next state 
@export var wait_time: float = 1:
	set(new_value):
		wait_time = max(new_value, 0)

# tp to player
# tp to random pos in given radius range
# tp x units back
# tp to team mate
@export var target: target_types

## used when teleporting to player or team member, to not land inside them
@export var offset: float = 0.5

@export var min_radius: float = 1
@export var max_radius: float = 5

@export var back: float = 2

@export_group("Debug")
## Show the paths during gameplay
@export var debug_show_path: bool = false

var nav_agent: NavigationAgent3D
var done: bool = false

func setup(_parent: Enemy, _animation_tree: AnimationTree):
	super (_parent, _animation_tree)

func enter():
	super()
	find_new_target()

func physics_process(_delta: float) -> State:
	if (done): return return_next()

	return null

func find_new_target():
	var tp_position: Vector3 = parent.position
	
	match target:
		target_types.PLAYER:
			#print(get_tree().get_nodes_in_group("Player")[0])
			var near_player = get_tree().get_nodes_in_group("Player")[0].global_position + (Vector3(randf_range(-1, 1),0.0,randf_range(-1, 1)).normalized() * offset)
			tp_position = get_point_on_map(near_player, 0.2)
			
		target_types.RANDOM:
			var random_position := Vector3.ZERO
			var attempts := 0
			var max_attempts := 100

			while get_point_on_map(random_position, 0) == Vector3.ZERO and attempts < max_attempts:
				random_position.x = randf_range(-1, 1)
				random_position.z = randf_range(-1, 1)
				random_position = random_position.normalized() * randf_range(min_radius, max_radius)
				random_position.y = 0.5 #TODO: warum ist das NavMesh bei y=0.5
				tp_position = get_point_on_map(random_position, 0) * Vector3(1,0,1)
				attempts += 1

			if attempts >= max_attempts:
				print("Warning: Could not find valid point on navmesh after ", max_attempts, " attempts.")
	
		target_types.TEAMMEMBER:
			var group: Array[StringName] = parent.get_groups()
			#print("group: ",group)
			var targets = get_tree().get_nodes_in_group(group[0])
			if len(targets) > 1:
				var member
				while true:
					member = targets[randi_range(0, len(targets)-1)]
					if not member == parent:
						break
				tp_position = member.global_position + (Vector3(randf_range(-1, 1),0.0,randf_range(-1, 1)).normalized() * offset)
		
		target_types.BACK:
			var back_position = parent.position + (parent.global_transform.basis.z * back) + Vector3(0,0.5,0)
			tp_position = get_point_on_map(back_position,0.2) * Vector3(1,0,1)
			#TODO: the npcs only rotate their visuals forward vector never changes
		
	parent.position = tp_position
	await get_tree().create_timer(wait_time).timeout
	done = true

func get_point_on_map(target_point: Vector3, min_dist_from_edge: float) -> Vector3:
	var map := parent.get_world_3d().navigation_map
	var closest_point := NavigationServer3D.map_get_closest_point(map, target_point)
	var delta := closest_point - target_point
	#print("target: ", target_point," , closest: ", closest_point, "delta: ", delta)
	var is_on_map = delta.is_zero_approx()
	if not is_on_map and min_dist_from_edge > 0:
		# Wasn't on the map, so push in from edge. If you have thin sections on
		# your navmesh, this could push it back off the navmesh!
		delta = delta.normalized()
		closest_point += delta * min_dist_from_edge
	elif not is_on_map:
		closest_point = Vector3.ZERO
	return closest_point
