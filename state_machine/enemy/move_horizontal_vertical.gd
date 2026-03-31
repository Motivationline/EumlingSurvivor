@tool
extends State
## Moves the Enemy horizontal or vertical.
## 
## Ends when the point is reached.
class_name MoveHorizontalVerticalState


## this entity moves until this ray hits something
@export var distance_check_ray: RayCast3D:
	set(value):
		distance_check_ray = value
		update_configuration_warnings()


func enter():
	super()
	find_new_direction()
	

func physics_process(_delta: float) -> State:
	if distance_check_ray.is_colliding():
		return return_next()
	parent.velocity = parent.visuals.transform.basis * Vector3.FORWARD * parent.speed

	parent.move_and_slide()
	return null

func find_new_direction():
	var directions: Array[int] = [0, 1, 2, 3]
	directions.shuffle()
	for direction in directions:
		parent.visuals.rotation.y = direction * PI / 2
		distance_check_ray.force_raycast_update()
		if not distance_check_ray.is_colliding():
			return
	push_warning("Didn't find a direction to move to. Am I stuck?")	

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := super ()
	if not distance_check_ray:
		warnings.insert(0, "A Distance Check Ray is required for this state to work properly.")
	return warnings
