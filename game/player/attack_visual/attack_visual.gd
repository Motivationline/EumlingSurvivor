extends Node3D
@onready var polygon: CSGPolygon3D = $Polygon
@onready var path: Path3D = $Path
@onready var ray_cast: RayCast3D = $RayCast3D


var max_length: float = 2.0:
	set(value):
		max_length = value
		for ray in ray_casts:
			ray.target_position.z = - max_length

var width: float = 0.2:
	set(value):
		width = value
		_update_polygon()
		_update_ray_positions()

@export var active_material: Material
@export var cooldown_material: Material

var on_cooldown: bool: 
	set(value):
		on_cooldown = value
		if on_cooldown:
			polygon.material = cooldown_material
		else:
			polygon.material = active_material


func _update_polygon():
	var half_width = width / 2
	var new_polygon: PackedVector2Array = [
		Vector2(-half_width, 0.0),
		Vector2(-half_width, 0.01),
		Vector2(half_width, 0.01),
		Vector2(half_width, 0.0),
	]

	polygon.polygon = new_polygon

var ray_casts: Array[RayCast3D] = []
func _update_ray_positions() -> void:
	var half_width = width / 2
	ray_casts[0].position.x = half_width
	ray_casts[2].position.x = -half_width


func _ready() -> void:
	var left_ray: RayCast3D = ray_cast.duplicate()
	var right_ray: RayCast3D = ray_cast.duplicate()
	add_child(left_ray)
	add_child(right_ray)
	ray_casts = [left_ray, ray_cast, right_ray]
	_update_ray_positions()

func _process(_delta: float) -> void:
	var length = max_length
	for ray in ray_casts:
		if ray.is_colliding():
			var current_collision := ray_cast.get_collision_point()
			var distance = current_collision.distance_to(global_position)
			length = max(0.01, min(distance, length))
	path.curve.remove_point(1)
	path.curve.add_point(Vector3(0, 0, -length))
