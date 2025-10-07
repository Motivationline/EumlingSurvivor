extends ProjectileTargetStrategy
## sets the target to the closest enemy
class_name TargetForwardProjectileTargetStrategy

func find_target():
	var forward_target = Node3D.new()
	var debug_mesh = MeshInstance3D.new()
	debug_mesh.mesh = BoxMesh.new()
	forward_target.add_child(debug_mesh)
	forward_target.position = parent.position + (-owner.get_global_transform().basis.z * 1)
	parent.add_child(forward_target)
	targets.append(forward_target)
	print(forward_target.position)
