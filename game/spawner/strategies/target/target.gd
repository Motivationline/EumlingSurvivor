extends Resource
class_name TargetStrategy

func get_target_position(_parent: Node3D) -> Vector3: return _parent.global_position - _parent.basis.z
