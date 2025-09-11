@tool
extends Node3D
class_name AOE

# ⚠
# I saw in the docs that we may never scale a hitbox other than setting proper values, so I did this to scale it direclty.
# Do not try to scale the hitbox by just scaling the entire node.
# ⚠

## If set to true, duration doesn't have any effect
@export var never_expire: bool = false
## How long does this aoe stay around before it removes itself
@export var duration: float = 1:
	set(new_value):
		duration = max(new_value, 0)
		update_configuration_warnings()
## How the size should change over time. Can be left empty for no scaling.
@export var size_scaler: Curve
## How much each axis of the visuals is affected by scaling. 0 - 1 is supported.
@export var scale_affects: Vector3 = Vector3.ONE

## The shape of the hitbox. [color=red]This will overwrite whatever you set inside the Hitbox![/color]
@export var shape: Shape3D:
	set(new_value):
		shape = new_value
		if (collsion_shape):
			collsion_shape.shape = shape
		update_configuration_warnings()

@export_group("No Touchy")
## The collision shape of the hitbox
@export var collsion_shape: CollisionShape3D
## The visuals to scale visually
@export var visuals: Node3D

var current_duration: float = 0
var original_size # no type hint because it can be different things
var original_scale: Vector3

func _ready() -> void:
	if (Engine.is_editor_hint()): child_order_changed.connect(update_configuration_warnings)
	save_initial_size()
	original_scale = visuals.scale

func _physics_process(delta: float) -> void:
	if (Engine.is_editor_hint()): return
	current_duration += delta
	if (current_duration > duration && !never_expire):
		queue_free()
		return

	if (size_scaler):
		var current_size: float = size_scaler.sample(fmod((current_duration / duration), size_scaler.max_domain))
		adjust_size_visuals(current_size)
		adjust_size_shape(current_size)

func save_initial_size():
	if (shape is SphereShape3D):
		original_size = shape.radius
	if (shape is BoxShape3D):
		original_size = shape.size
	if (shape is CylinderShape3D):
		original_size = shape.radius

func adjust_size_shape(size: float):
	if (!shape): return
	if (shape is SphereShape3D):
		shape.radius = original_size * size
	elif (shape is BoxShape3D):
		shape.size = original_size * size
	elif (shape is CylinderShape3D):
		shape.radius = original_size * size

func adjust_size_visuals(size: float):
	var remaining_of_original = Vector3.ONE - scale_affects
	var new_scale = (remaining_of_original * original_scale) + (scale_affects * size)
	visuals.scale = new_scale if (!new_scale.is_zero_approx()) else Vector3.UP * 0.01 # a scale of 0 0 0 causes issues, so we're setting it to 0 0.01 0 instead.

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if (!shape): warnings.append("Needs a shape for the collision.")
	if (shape):
		if (!(shape is SphereShape3D) && !(shape is BoxShape3D) && !(shape is CylinderShape3D)): warnings.append("For the size modificator to work, Shape has to be Sphere, Cylinder or Box.")
	if (!collsion_shape): warnings.append("Collision Shape needs to be set!")
	if (get_child_count() > 2): warnings.append("It is not recommended to add nodes outside of the 'Visuals' Node, as they wouldn't scale with the rest.")
	return warnings
