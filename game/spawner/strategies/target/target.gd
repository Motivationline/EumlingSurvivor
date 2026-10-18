@abstract
extends Resource
class_name TargetStrategy

func get_target_position(_parent: Transform3D) -> Vector3: return _parent.origin - _parent.basis.z
