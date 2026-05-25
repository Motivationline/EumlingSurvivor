@tool
extends State

## Moves the Entity along a specified Path3D node.
class_name FollowPathState

## Name of the Path3D node to follow. The Path3D node must be a child of a Paths node, which in turn must be a child of the Level node.
@export var path_name: String = ""
## When true, the Entity will begin the path from the start after reaching the end.
## The 'Curve > Closed' option on the Path3D node can be used to close the path. 
@export var loop_path: bool = false
## Whether the entity should return to the path when it is off the path
@export var return_to_path: bool = false

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
	done = !return_to_path

func handle_off_path(progress: float, delta_speed: float) -> bool:
	var path_position: Vector3 = path.curve.sample_baked(progress)
	var distance_to_path: float = parent.global_position.distance_to(path_position)
	var is_off_path: bool = delta_speed < distance_to_path
	done = is_off_path and not return_to_path
	return is_off_path

func handle_path_end_reached(future_progress: float, is_off_path: bool) -> float:
	if loop_path:
		return fposmod(future_progress, path_length)

	if is_off_path:
		return 0.0
	
	done = true
	return path_length

func physics_process(delta: float) -> State:
	if done: return return_next()

	var speed: float = speed_override if speed_override_active else parent.speed
	var delta_speed: float = speed * delta

	var progress: float = path.curve.get_closest_offset(parent.global_position)
	var future_progress: float = progress + delta_speed

	var is_off_path: bool = handle_off_path(progress, delta_speed)

	# Check whether the Entity will reach the path end in the next movement step.
	if future_progress > path_length:
		future_progress = handle_path_end_reached(future_progress, is_off_path)

	var next_path_position: Vector3 = path.curve.sample_baked(future_progress)
	var direction: Vector3 = (next_path_position - parent.global_position).normalized()

	parent.velocity = direction * speed
	parent.visuals.rotation.y = atan2(-parent.velocity.x, -parent.velocity.z)
	parent.move_and_slide()

	return null
