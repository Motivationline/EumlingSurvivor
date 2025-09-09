extends RotationStrategy
class_name RandomRotationStrategy

@export var max_negative: float = 0
@export var max_positive: float = 0


func apply_rotation(_instance: Node3D, _current: int, _max: int):
	var rotate_by = randf_range(max_negative, max_positive)
	_instance.rotate_y(deg_to_rad(rotate_by))