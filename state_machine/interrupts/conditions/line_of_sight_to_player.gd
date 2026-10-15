@tool
## Shoots a ray towards the player, returns true if the ray hits the player uninterrupted 
class_name LineOfSightToPlayerInterruptCondition extends InterruptCondition

func _ready() -> void:
	pass

func start():
	super()

func evaluate() -> bool:
	if !Player.player: return false
	var origin = parent.global_position + Vector3.UP * 0.5
	var player_position = Player.player.global_position + Vector3.UP * 0.5
	var query = PhysicsRayQueryParameters3D.create(origin, player_position)

	var space_state = parent.get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)
	
	return result.get("collider") == Player.player
