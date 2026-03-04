extends ProjectileMovementStrategy
## Moves the projectile in a parabolic way
class_name ArtilleryToTargetProjectileMovementStrategy

## value is the flight height, max domain is the flight length
@export var flight_curve: Curve

## minium distance the projectile should fly
@export var min_distance: float = 1
## maximum distance the projectile can reach 
@export var max_distance: float = 10


var start_pos: Vector3
var target_pos: Vector3

func _setup(_parent: CharacterBody3D, _owner: Node3D) -> void:
	super (_parent, _owner)
	start_pos = parent.global_position
	parent.velocity = Vector3.ZERO
	parent.creation_completed.connect(choose_target_position)

func choose_target_position():
	if parent is Projectile:
		var targets: Array[Node] = parent.get_targets()
		if targets.size() == 0:
			queue_free()
		var target = targets[0]
		target_pos = target.global_position
		var distance = clampf(target_pos.distance_to(start_pos), min_distance, max_distance)
		target_pos = start_pos + (target_pos - start_pos).normalized() * distance


func apply_movement(_delta: float, _current_lifetime: float, _total_lifetime: float) -> void:
	var height: float = flight_curve.sample(_current_lifetime)
	var new_position = (target_pos - start_pos) * (_current_lifetime / flight_curve.max_domain) + start_pos
	new_position.y = height
	parent.global_position = new_position