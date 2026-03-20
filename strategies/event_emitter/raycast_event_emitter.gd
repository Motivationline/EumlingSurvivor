@tool
## Emits an event whenever a raycast intersects with a defined entity
class_name RaycastEventEmitter extends EventEmitter

## The raycast to be checked with. [color=red]Make sure it has the correct collision masks set![/color]
@export var ray: RayCast3D

## how often should this event trigger?
## `continous`: Every (physics) frame that something is colliding with the ray, trigger the event
## `repeating`: Trigger the event every time something is colliding [i]again[/i] after it stopped colliding
## `once`: Trigger only the first time
@export_enum("continous", "repeating", "once") var trigger_mode = "once"

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not ray:
		warnings.append("Needs a ray to work")
	return warnings

var triggered_once: bool = false
var triggering_collider: Object = null

func _physics_process(_delta: float) -> void:
	if not ray: return
	if listeners.is_empty(): return

	match trigger_mode:
		"continous":
			if ray.is_colliding():
				_trigger(triggering_collider)

		"repeating":
			if ray.is_colliding():
				var collision = ray.get_collider()
				if collision != triggering_collider:
					triggering_collider = collision
					_trigger(triggering_collider)
			elif triggering_collider:
				triggering_collider = null

		"once":
			if triggered_once: return
			if ray.is_colliding():
				_trigger(ray.get_collider())
				triggered_once = true
