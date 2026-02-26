@tool
extends State
## Uses the levels NavMesh to move the Enemy to a random point inside the level
## 
## Ends when the point is reached.
class_name MoveHorizontalVerticalOnNavMeshState

# TODO: add controls over where we're going, e.g. values or an area or something

## How long to wait [b]after[/b] reaching the target location before proceeding to the next state 
@export var wait_time: float = 1:
	set(new_value):
		wait_time = max(new_value, 0)

## How far away from the current position is the minimum distance to walk to
@export var min_distance: float = 1
## How far away from the current position is the maximum distance to walk to
@export var max_distance: float = 5
## how many attempts the pathfinding can take before exiting the state
@export var max_pathing_trys: int = 8

## raycast to help pathing
@export var path_ray: RayCast3D

@export_group("Overrides")
## Movement Speed Override
@export_range(0, 100, 0.1) var speed_override: float = 1:
	set(new_value):
		speed_override = max(new_value, 0)
		update_configuration_warnings()
# Whether to apply the speed override
@export var speed_override_active: bool = false

@export_group("Debug")
## Show the paths during gameplay
@export var debug_show_path: bool = false

var nav_agent: NavigationAgent3D
var done: bool = false

func setup(_parent: Enemy, _animation_tree: AnimationTree):
	super (_parent, _animation_tree)
	nav_agent = NavigationAgent3D.new()
	parent.add_child(nav_agent)
	# anti-schwebe-zeugs - ist bisschen unklar, warum muss ich das auf 2x cell height setzen damit es richtig funktioniert? :shrug:
	nav_agent.path_height_offset = ProjectSettings.get_setting("navigation/3d/default_cell_height", 0.25) * 2
	nav_agent.navigation_finished.connect(target_reached)
	nav_agent.debug_enabled = debug_show_path

func enter():
	super()
	find_next_goal_position()

func physics_process(_delta: float) -> State:
	if (done): return return_next()
	if (nav_agent.is_navigation_finished()): return null
	var destination = nav_agent.get_final_position()
	var local_destination = destination - parent.global_position
	var direction = local_destination.normalized()
	var speed = speed_override if (speed_override_active) else parent.speed
	parent.velocity = direction * speed

	parent.move_and_slide()
	
	if path_ray.is_colliding():
		done = true

	#if (!direction.is_zero_approx()):
		#parent.visuals.look_at(parent.global_position + direction)
	parent.look_at(destination, Vector3.UP)

	return null

func find_next_goal_position():
	for i in range(max_pathing_trys):
		var random_position := Vector3.ZERO
		var random_orientation = randi() % 2
		#print(random_orientation)
		
		if random_orientation == 0:
			## were going horizontal
			random_position.x = randf_range(-1, 1)
		else:
			## were going vertical
			random_position.z = randf_range(-1, 1)
		
		
		random_position = random_position.normalized() * randf_range(min_distance, max_distance)
		nav_agent.target_position = random_position + parent.global_position
		
		done = false
		nav_agent.debug_enabled = debug_show_path
		
		#print(random_orientation)
		#print("final path: ", nav_agent.get_final_position())
		#print("pos: ", parent.global_position)
		#print("abs x: ", abs(nav_agent.get_final_position().x - parent.global_position.x))
		#print("abs z: ", abs(nav_agent.get_final_position().z - parent.global_position.z))
		
		if random_orientation == 0 && abs(nav_agent.get_final_position().z - parent.global_position.z) > 0.01 || random_orientation == 1 && abs(nav_agent.get_final_position().x - parent.global_position.x) > 0.01:
			#print("invalid path, try again")
			
			if i == max_pathing_trys:
				#could not find a valid path -> exit state
				done = true
		else:
			#print("found a valid path")
			break
	
func target_reached():
	nav_agent.debug_enabled = false
	await get_tree().create_timer(wait_time).timeout
	done = true

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := super ()
	if (speed_override == 0 && speed_override_active): warnings.insert(0, "Using a speed of 0 means this node will never reach its target.")
	if (min_distance > max_distance): warnings.insert(0, "Min Distance cannot be larger than Max Distance")
	return warnings
