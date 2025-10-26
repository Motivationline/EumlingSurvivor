extends EventStrategy
## Removes the node when event is called
class_name BounceEventStrategy

@export var ray_cast: RayCast3D

func event_triggered(_data):
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
