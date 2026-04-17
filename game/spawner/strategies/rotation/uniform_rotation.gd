## Distributes all projectiles in a uniform manner inside the selected degrees
class_name UniformRotationStrategy extends RotationStrategy

@export var max_negative: float = 0
@export var max_positive: float = 0


func apply_rotation(_instance: Node3D, _current: int, _max: int):
	var max_range: float = max_positive - max_negative
	var rotate_by: float = 0
	if _max == 1:
		rotate_by = max_range / 2 + max_negative
	else:
		rotate_by = (max_range / max(0.5, _max - 1)) * _current + max_negative
	_instance.rotate_y(deg_to_rad(rotate_by))