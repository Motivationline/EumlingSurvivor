extends Resource
class_name TargetStrategy

func get_target_direction(_parent: Node3D) -> Vector3: return _parent.global_rotation
func get_target_position(_parent: Node3D) -> Vector3: return _parent.global_position