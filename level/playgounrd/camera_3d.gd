extends Camera3D

@export var view_limit_lower_x: float = -100000000
@export var view_limit_upper_x: float = 100000000
@export var view_limit_lower_z: float = -100000000
@export var view_limit_upper_z: float = 100000000

var player: CharacterBody3D

var offset_x = 0.0
var offset_z = 0.0
var floor_plane = Plane(Vector3.UP)

func _ready() -> void:
	player = get_tree().get_nodes_in_group("Player")[0]
	player.camera = self
	offset_x = position.x
	offset_z = position.z

func _process(_delta: float) -> void:
	pass

func _physics_process(_delta: float) -> void:
	if player == null:
		return
	
	var next_pos: Vector3 = Vector3(player.global_position.x + offset_x, global_position.y, player.global_position.z + offset_z)
	global_position = global_position.lerp(next_pos, 0.1)

	var visible_rect = get_visible_parts_of_plane(floor_plane)

	# prints("visible area", visible_rect.position, visible_rect.end)

	if (visible_rect.position.x < view_limit_lower_x):
		global_position.x += view_limit_lower_x - visible_rect.position.x
	if (visible_rect.end.x > view_limit_upper_x):
		global_position.x += view_limit_upper_x - visible_rect.end.x

	if (visible_rect.position.y < view_limit_lower_z):
		global_position.z += view_limit_lower_z - visible_rect.position.y
	if (visible_rect.end.y > view_limit_upper_z):
		global_position.z += view_limit_upper_z - visible_rect.end.y


func get_visible_parts_of_plane(plane: Plane) -> Rect2:
	# check if next position is showing within bounding boxes
	var top_left: Vector2 = Vector2(0, 0)
	var bottom_right: Vector2 = get_viewport().get_visible_rect().size

	var top_left_origin = project_ray_origin(top_left)
	var bottom_right_origin = project_ray_origin(bottom_right)

	var top_left_normal = project_ray_normal(top_left)
	var bottom_right_normal = project_ray_normal(bottom_right)

	var top_left_hit: Vector3 = plane.intersects_ray(top_left_origin, top_left_normal)
	var bottom_right_hit: Vector3 = plane.intersects_ray(bottom_right_origin, bottom_right_normal)

	return Rect2(top_left_hit.x, top_left_hit.z, bottom_right_hit.x - top_left_hit.x, bottom_right_hit.z - top_left_hit.z)
