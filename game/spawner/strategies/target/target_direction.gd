extends TargetStrategy
class_name DirectionTargetStrategy

@export_enum("local", "global") var mode = "local"
## +Z is backwards, -Z is forwards, +X is right, -X is left
@export var direction: Vector3

func get_target_position(_parent: Node3D) -> Vector3:
	match mode:
		"local":
			return _parent.global_position + _parent.basis * direction
		"global":
			return _parent.global_position + direction
		_: return super(_parent)