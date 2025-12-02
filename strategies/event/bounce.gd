@tool
extends EventStrategy
## Makes the projectile bounce off if it hits the Level
class_name BounceEventStrategy

## requiers a RayCast3D at the Tip of the projectile facing forward and reaching out of the Hitbox
@export var ray_cast: RayCast3D:
	set(value):
		ray_cast = value
		if Engine.is_editor_hint():
			update_configuration_warnings()

func event_triggered(_data):
	
	if not Engine.is_editor_hint():
		update_configuration_warnings()
	#print("triggered bounce")
	if ray_cast.is_colliding():
		#print("raycast hit")
		var hit = ray_cast.get_collider()
		#print("Hit: ", hit)
		if hit in get_tree().get_nodes_in_group("Level"):
			#print("hit is in Level")
			var hit_normal = ray_cast.get_collision_normal()
			#print("old velocity: ", parent.velocity)
			parent.velocity = parent.velocity.bounce(hit_normal)
			#print("new velocity: ", parent.velocity)


func _get_configuration_warning():
	if not ray_cast.typeof(RayCast3D):
		return ["expect a RayCast3D for bounce to work"]
	return []
