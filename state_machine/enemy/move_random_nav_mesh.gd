@tool
extends State
## Uses the levels NavMesh to move the Enemy to a random point inside the level
## 
## Ends when the point is reached.
class_name MoveRandomOnNavMeshState

## How long to wait [b]after[/b] reaching the target location before proceeding to the next state 
@export var wait_time: float = 1:
	set(new_value):
		wait_time = max(new_value, 0)

# TODO: add more controls over where we're going, e.g. an area or something
enum TARGET_TYPES {SELF, PLAYER}
@export_group("Where to go")
## Around which point to find a new target position
@export var target: TARGET_TYPES = TARGET_TYPES.SELF

## How far away from the target position is the minimum distance to walk to
@export var min_distance: float = 1
## How far away from the target position is the maximum distance to walk to
@export var max_distance: float = 5

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

func setup(_parent: StateMachinePoweredEntity, _animation_tree: AnimationTree):
	super (_parent, _animation_tree)
	nav_agent = NavigationAgent3D.new()
	parent.add_child(nav_agent)
	# anti-schwebe-zeugs - ist bisschen unklar, warum muss ich das auf 2x cell height setzen damit es richtig funktioniert? :shrug:
	nav_agent.path_height_offset = ProjectSettings.get_setting("navigation/3d/default_cell_height", 0.25) * 2
	nav_agent.navigation_finished.connect(target_reached)
	nav_agent.debug_enabled = debug_show_path
	nav_agent.target_desired_distance = 0.1
	nav_agent.path_desired_distance = 0.1

func enter():
	super ()
	find_new_target()

func physics_process(_delta: float) -> State:
	if (done): return return_next()
	if (nav_agent.is_navigation_finished()): return null
	var destination = nav_agent.get_next_path_position()
	var local_destination = destination - parent.global_position
	var direction = local_destination.normalized()
	var speed = speed_override if (speed_override_active) else parent.speed
	parent.velocity = direction * speed

	parent.move_and_slide()

	if (!direction.is_zero_approx()):
		parent.visuals.look_at(parent.global_position + direction)

	return null

func find_new_target():
	var best_position := Vector3.ZERO
	var best_squared_distance: float = max_distance * max_distance + 1
	var target_position: Vector3 = Vector3.ZERO
	match target:
		TARGET_TYPES.SELF:
			target_position = parent.global_position
		TARGET_TYPES.PLAYER:
			var player = get_tree().get_first_node_in_group("Player") as Player
			if player:
				target_position = player.global_position

	for i in 5:
		# try 5 times to find a spot that is closest to reachable
		var random_position := Vector3.ZERO
		random_position.x = randf_range(-1, 1)
		random_position.z = randf_range(-1, 1)
		random_position = random_position.normalized() * randf_range(min_distance, max_distance)
		nav_agent.target_position = random_position + target_position
		var distance = nav_agent.get_final_position().distance_squared_to(nav_agent.target_position)
		if distance < best_squared_distance:
			best_position = random_position
			best_squared_distance = distance
		if distance <= 0.01:
			break
		
	nav_agent.target_position = best_position + target_position
	done = false
	nav_agent.debug_enabled = debug_show_path

func target_reached():
	nav_agent.debug_enabled = false
	await get_tree().create_timer(wait_time).timeout
	done = true

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := super ()
	if (speed_override == 0 && speed_override_active): warnings.insert(0, "Using a speed of 0 means this node will never reach its target.")
	if (min_distance > max_distance): warnings.insert(0, "Min Distance cannot be larger than Max Distance")
	return warnings
