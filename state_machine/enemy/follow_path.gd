@tool
class_name FollowPathState
extends State
## Moves the Entity along a specified Path3D node.

enum PathEndBehavior {
	## Go to the next state.
	EXIT,
	## Begin the path again.
	LOOP,
	## Walk the path backwards.
	REVERSE,
}

## Name of the Path3D node to follow. The Path3D node must be a child of a Paths node, which in turn must be a child of the Level node.
@export var path_name: String = ""
## What the Entity will do after reaching the path end.
@export var path_end_behavior: PathEndBehavior = PathEndBehavior.EXIT
## The amount of time to stay on the path. Goes to the next state after running out. Will never run out if negative.
@export var exit_time: float = -1.0
## Walk the path backwards.
@export var reverse: bool = false
## Whether the entity should return to the path when it is off the path
@export var return_to_path: bool = false

@export_group("Random Exit Time")
## Optional random exit time overwrite.
@export var random: bool = false
## Minimum exit time.
@export var min_exit_time: float = 0.0
## Maximum exit time.
@export var max_exit_time: float = 1.0

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
var progress: float
var timer: SceneTreeTimer
var done: bool = false


func enter() -> void:
	super()

	setup_path()

	if random:
		exit_time = randf_range(min_exit_time, max_exit_time)
	
	if exit_time >= 0.0:
		timer = get_tree().create_timer(exit_time)
		timer.timeout.connect(handle_timeout)


func exit() -> void:
	super()

	if timer and timer.timeout.is_connected(handle_timeout):
		timer.timeout.disconnect(handle_timeout)

	done = not return_to_path


func setup_path() -> void:
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

	progress = path.curve.get_closest_offset(parent.global_position)
	if progress == 0.0 and reverse:
		progress = path_length


func handle_timeout() -> void:
	done = true


func is_off_path(delta_speed: float) -> float:
	var path_position: Vector3 = path.curve.sample_baked(progress)
	var distance_to_path: float = parent.global_position.distance_to(path_position)
	return delta_speed < distance_to_path


func handle_off_path() -> float:
	if not return_to_path:
		done = true
		return progress

	if progress == 0.0 and reverse:
		return path_length
	if progress == path_length and not reverse:
		return 0.0
	return progress


func get_future_progress(delta_speed: float) -> float:
	if is_off_path(delta_speed):
		return handle_off_path()

	var future_progress: float = progress - delta_speed if reverse else progress + delta_speed

	if future_progress <= path_length and future_progress >= 0.0:
		return future_progress
	
	match path_end_behavior:
		PathEndBehavior.LOOP:
			return fposmod(future_progress, path_length)
		PathEndBehavior.REVERSE:
			reverse = not reverse
		PathEndBehavior.EXIT:
			done = true

	return 0.0 if future_progress < 0.0 else path_length


func physics_process(delta: float) -> State:	
	var speed: float = speed_override if speed_override_active else parent.speed
	var delta_speed: float = speed * delta

	progress = get_future_progress(delta_speed)

	if done: return return_next()

	var next_path_position: Vector3 = path.curve.sample_baked(progress)
	var direction: Vector3 = (next_path_position - parent.global_position).normalized()

	parent.velocity = direction * speed
	parent.visuals.rotation.y = atan2(-parent.velocity.x, -parent.velocity.z)
	parent.move_and_slide()

	return null
