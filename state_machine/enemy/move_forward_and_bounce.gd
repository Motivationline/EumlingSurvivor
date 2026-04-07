@tool
class_name MoveForwardAndBounceState extends MoveForwardState


var velocity: Vector3 = Vector3.BACK
func enter():
	super()
	velocity = -parent.visuals.basis.z.normalized()
	prints("velocity", velocity)


func physics_process(_delta: float) -> State:
	if (end_condition_reached()):
		return return_next()
	
	var speed = speed_override if (speed_override_active) else parent.speed
	var new_velocity = velocity * speed * _delta
	var collision := parent.move_and_collide(new_velocity)
	if collision:
		velocity = velocity.bounce(collision.get_normal())
	
	
	return null
