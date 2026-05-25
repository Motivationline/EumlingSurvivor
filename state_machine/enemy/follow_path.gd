@tool
extends State

## Moves the Entity along a specified Path3D node.
class_name FollowPathState

## Name of the Path3D node to follow. The Path3D node must be a child of a Paths node, which in turn must be a child of the Level node.
@export var path_name: String = ""
## When true, the Entity will begin the path from the start after reaching the end.
## The 'Curve > Closed' option on the Path3D node can be used to close the path. 
@export var loop_path: bool = false

@export_group("Overrides")
## Movement Speed Override
@export_range(0, 100, 0.1) var speed_override: float = 1:
	set(new_value):
		speed_override = max(new_value, 0)
		update_configuration_warnings()
## Whether to apply the speed override
@export var speed_override_active: bool = false

var path: Path3D
var path_length: float
var done: bool = false

func setup(_parent: StateMachinePoweredEntity, _animation_tree: AnimationTree) -> void:
	super (_parent, _animation_tree)
	parent = _parent

	var level: Node = get_tree().get_first_node_in_group("Level")
	if not level:
		push_error("Could not find the level.")

	var paths: Node = level.get_node_or_null("Paths")
	if not paths:
		push_error("Could not find a paths node in the level.")

	path = paths.get_node_or_null(path_name)
	if not path:
		push_error("Could not find the path '", path_name, "' in the paths node.")

	if not path.curve:
		push_error("Path '", path_name, "' has no curve set.")

	path_length = path.curve.get_baked_length()

func exit() -> void:
	done = false

func handle_path_end_reached(progress: float, future_progress: float, delta_speed: float) -> float:
	if loop_path:
		return fposmod(future_progress, path_length)

	var path_position: Vector3 = path.curve.sample_baked(progress)
	# Check if the Entity is off the path
	if delta_speed < parent.global_position.distance_to(path_position):
		return 0.0
	
	done = true
	return path_length

func physics_process(delta: float) -> State:
	if done: return return_next()

	var progress: float = path.curve.get_closest_offset(parent.global_position)
	var speed: float = speed_override if speed_override_active else parent.speed
	var future_progress: float = progress + (speed * delta)

	# Check whether the Entity will reach the path end in the next movement step.
	if future_progress > path_length:
		future_progress = handle_path_end_reached(progress, future_progress, speed * delta)

	var next_path_position: Vector3 = path.curve.sample_baked(future_progress)
	var direction: Vector3 = (next_path_position - parent.global_position).normalized()

	parent.velocity = direction * speed
	parent.visuals.rotation.y = atan2(-parent.velocity.x, -parent.velocity.z)
	parent.move_and_slide()

	return null
