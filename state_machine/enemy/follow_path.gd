@tool
extends State

## Moves the Entity along a specified Path
class_name FollowPathState

## Name of the Path3D node to follow. Must be a child of a Paths node, which in turn must be a child of the Level node
@export var path_name: String = ""

@export_group("Overrides")
## Movement Speed Override
@export_range(0, 100, 0.1) var speed_override: float = 1:
	set(new_value):
		speed_override = max(new_value, 0)
		update_configuration_warnings()
## Whether to apply the speed override
@export var speed_override_active: bool = false

var path: Path3D
var correction_strength: float = 1.0

func setup(_parent: StateMachinePoweredEntity, _animation_tree: AnimationTree):
	super (_parent, _animation_tree)
	parent = _parent
	
	# TODO: Clarify if collision is needed
	parent.get_node("CollisionShape3D").disabled = false
	
	var level: Node = get_tree().get_first_node_in_group("Level")
	if not level:
		# TODO: add warning
		return
	
	var paths: Node3D = level.get_node_or_null("Paths")
	if not paths:
		# TODO: add warning
		return

	path = paths.get_node_or_null(path_name)
	if not path:
		# TODO: add warning
		return

# TODO: Finalize on the approach when end of path is reached (Probably just a loop/reverse/change_state option)
# TODO: Finalize on the approach when Entity is off the path (Probably a seperate get_to_path state and a change_state option)
# TODO: Finalize on the approach when path is blocked (Wait for clarification on wether collision is needed)
func physics_process(_delta: float) -> State:
	var progress = path.curve.get_closest_offset(parent.global_position)

	var path_pos = path.curve.sample_baked(progress)
	var ahead = path.curve.sample_baked(progress + 0.1)
	var tangent = (ahead - path_pos).normalized()
	var correction = path_pos - parent.global_position
	var direction = (tangent + correction * correction_strength).normalized()
	
	var speed = speed_override if speed_override_active else parent.speed
	parent.velocity = direction * speed
	parent.move_and_slide()
	
	parent.visuals.rotation.y = atan2(-parent.velocity.x, -parent.velocity.z)

	return null
