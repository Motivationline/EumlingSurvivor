extends ProjectileTargetStrategy
## sets the target to the closest enemy
class_name TargetForwardProjectileTargetStrategy

func find_target():
	if parent.targets.is_empty() or parent.targets[0].name != "forward":
		parent._clear_targets()
		
		var forward_target = Node3D.new()
		forward_target.name = "forward"
		var debug_mesh = MeshInstance3D.new()
		debug_mesh.mesh = BoxMesh.new()
		#forward_target.add_child(debug_mesh)

		forward_target.position = owning_entity.velocity.normalized() * 100 + parent.position - owning_entity.position
		parent.add_child(forward_target)
		
		parent.targets.append(forward_target)
		#print(forward_target.position)
		#print(targets)
