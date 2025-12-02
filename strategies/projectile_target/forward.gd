extends ProjectileTargetStrategy
## sets the target to be infront of the entity
class_name TargetForwardProjectileTargetStrategy

@export var target_distance: float = 100

func find_target():
	if parent.targets.is_empty() or parent.targets[0].name != "forward":
		parent.clear_targets()
		
		var forward_target = Node3D.new()
		forward_target.name = "forward"
		#var debug_mesh = MeshInstance3D.new()
		#debug_mesh.mesh = BoxMesh.new()
		#forward_target.add_child(debug_mesh)

		forward_target.position = owning_entity.velocity.normalized() * target_distance + parent.position - owning_entity.position
		parent.add_child(forward_target)
		
		return [forward_target]
