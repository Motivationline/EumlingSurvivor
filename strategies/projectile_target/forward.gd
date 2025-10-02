extends ProjectileTargetStrategy
## sets the target to the closest enemy
class_name TargetForwardProjectileTargetStrategy

func find_target():
	var forward_target = Node3D.new()
	forward_target.position = parent.position + (-parent.get_global_transform_interpolated().basis.z * 1000)
	parent.add_child(forward_target)
	targets.append(forward_target)
