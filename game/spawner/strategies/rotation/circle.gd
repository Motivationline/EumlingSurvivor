extends RotationStrategy
class_name CircleRotationStrategy

func apply_rotation(_instance: Node3D, _current: int, _max: int):
	var angle = (TAU / _max) * _current
	_instance.rotate_y(angle)
