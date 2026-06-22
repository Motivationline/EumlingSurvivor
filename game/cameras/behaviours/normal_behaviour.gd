class_name NormalBehaviour
extends CameraBehaviour
## Follows the player.

@export var view_limit_lower_x: float = -100000000
@export var view_limit_upper_x: float = 100000000
@export var view_limit_lower_z: float = -100000000
@export var view_limit_upper_z: float = 100000000

var floor_plane := Plane(Vector3.UP)


func setup(_camera: GameCamera) -> void:
	pass


func update_camera(camera: GameCamera) -> void:
	if not camera.player:
		return

	var next_pos := Vector3(
			camera.player.global_position.x + camera.offset_x,
			camera.global_position.y,
			camera.player.global_position.z + camera.offset_z)
	camera.global_position = camera.global_position.lerp(next_pos, 0.1)

	var visible_rect: Rect2 = get_visible_parts_of_plane(floor_plane, camera)

	if (visible_rect.position.x < view_limit_lower_x):
		camera.global_position.x += view_limit_lower_x - visible_rect.position.x
	if (visible_rect.end.x > view_limit_upper_x):
		camera.global_position.x += view_limit_upper_x - visible_rect.end.x

	if (visible_rect.position.y < view_limit_lower_z):
		camera.global_position.z += view_limit_lower_z - visible_rect.position.y
	if (visible_rect.end.y > view_limit_upper_z):
		camera.global_position.z += view_limit_upper_z - visible_rect.end.y


func get_visible_parts_of_plane(plane: Plane, camera: GameCamera) -> Rect2:
	# check if next position is showing within bounding boxes
	var top_left: Vector2 = Vector2(0, 0)
	var bottom_right: Vector2 = camera.get_viewport().get_visible_rect().size

	var top_left_origin: Vector3 = camera.project_ray_origin(top_left)
	var bottom_right_origin: Vector3 = camera.project_ray_origin(bottom_right)

	var top_left_normal: Vector3 = camera.project_ray_normal(top_left)
	var bottom_right_normal: Vector3 = camera.project_ray_normal(bottom_right)

	var top_left_hit: Vector3 = plane.intersects_ray(top_left_origin, top_left_normal)
	var bottom_right_hit: Vector3 = plane.intersects_ray(bottom_right_origin, bottom_right_normal)

	return Rect2(top_left_hit.x, top_left_hit.z, bottom_right_hit.x - top_left_hit.x, bottom_right_hit.z - top_left_hit.z)
