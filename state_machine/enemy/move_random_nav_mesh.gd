@tool
extends State
class_name MoveRandomOnNavMeshState

# TODO: add controls over where we're going, e.g. values or an area or something

@export var speed: float = 1
@export var wait_time: float = 1

@export_category("Debug")
@export var debug_show_path: bool

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
	return null

func find_new_target():
	var random_position := Vector3.ZERO
	random_position.x = randf_range(-10, 10)
	random_position.z = randf_range(-10, 10)
	nav_agent.target_position = random_position
	done = false

func target_reached():
	await get_tree().create_timer(wait_time).timeout
	done = true
