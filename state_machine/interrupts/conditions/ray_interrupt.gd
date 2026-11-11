@tool
## Evaluate Custom Ray Collisions
class_name RayInterruptCondition extends InterruptCondition

## The ray to check for.
## [color=red]Make sure to set the correct Collsion Mask![/color]
@export var ray: RayCast3D:
	set(value):
		ray = value
		update_configuration_warnings()

func _ready() -> void:
	update_configuration_warnings()

func evaluate() -> bool:
	if ray and ray.is_colliding():
		return true
	return false

func _get_configuration_warnings() -> PackedStringArray:
	if not ray:
		return ["You didn't assign a ray to this interrupt. It will always evaluate to false."]
	
	return []