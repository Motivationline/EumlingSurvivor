@tool
extends State
## Uses the levels NavMesh to move the Enemy to a random point inside the level
## 
## Ends when the point is reached.
class_name MoveRandomOnNavMeshState

# TODO: add controls over where we're going, e.g. values or an area or something

## How fast to move
@export var speed: float = 1:
	set(new_value):
		speed = max(new_value, 0)
		update_configuration_warnings()
## How long to wait [b]after[/b] reaching the target location before proceeding to the next state 
@export var wait_time: float = 1:
	set(new_value):
		wait_time = max(new_value, 0)

@export_group("Debug")
## Show the paths during gameplay
@export var debug_show_path: bool = false

var nav_agent: NavigationAgent3D
var done: bool = false

func setup(_parent: Node):
	super (_parent)
	nav_agent = NavigationAgent3D.new()
	parent.add_child(nav_agent)
	nav_agent.navigation_finished.connect(target_reached)
	nav_agent.debug_enabled = debug_show_path

func enter():
	find_new_target()

func physics_process(_delta: float) -> State:
	if (done): return return_next()
	if (nav_agent.is_navigation_finished()): return null
	var destination = nav_agent.get_next_path_position()
	var local_destination = destination - parent.global_position
	var direction = local_destination.normalized()
	parent.velocity = direction * speed

	parent.move_and_slide()

	if (!direction.is_zero_approx()):
		parent.look_at(parent.global_position + direction)

	return null

func find_new_target():
	var random_position := Vector3.ZERO
	random_position.x = randf_range(-10, 10)
	random_position.z = randf_range(-10, 10)
	nav_agent.target_position = random_position
	done = false
	nav_agent.debug_enabled = debug_show_path

func target_reached():
	nav_agent.debug_enabled = false
	await get_tree().create_timer(wait_time).timeout
	done = true

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := super ()
	if (speed == 0): warnings.insert(0, "Using a speed of 0 means this node will never reach its target.")
	return warnings