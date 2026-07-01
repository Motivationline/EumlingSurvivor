class_name BossBehaviour
extends CameraBehaviour
## Will keep the player and the specified boss visisble by adjusting its position and size.

@export_node_path("Enemy") var boss: NodePath = ""
## Extra margin around the player.
@export var player_size: float = 2.0
## Extra margin around the boss.
@export var boss_size: float = 2.0
## The camera will position itself between the boss and the player.
## With 0.5 the camera will be exactly in the middle.
## With 0.0 the camera will be exactly over the player.
## With 1.0 the camera will be exactly over the boss.
@export_range(0.0, 1.0, 0.001) var player_boss_position_ratio: float = 0.5
## The minimun size of the camera.
@export var min_size: float = 5.0

var _boss: Node3D
var aspect_ratio: float = 16.0 / 9.0
var covered_by_healthbar: float = 1.0


func setup(camera: GameCamera) -> void:
	_boss = camera.get_node(boss)

	var viewport_size: Vector2 = camera.get_viewport().get_visible_rect().size
	aspect_ratio = viewport_size.x / viewport_size.y
	
	var healthbar_height: float = _get_healthbar_height()
	covered_by_healthbar = healthbar_height / viewport_size.y


func update_camera(camera: GameCamera) -> void:
	if not camera.player or not _boss or not _boss.is_inside_tree():
		camera.switch_to_behaviour()
		return

	var player_position: Vector3 = camera.player.global_position
	var boss_position: Vector3 = _boss.global_position

	var direction: Vector3 = player_position - boss_position
	direction.y = 0.0
	direction = direction.normalized()
	
	var view_direction: Vector3 = -camera.global_transform.basis.z
	view_direction.y = 0.0
	view_direction = view_direction.normalized()
	var right_direction := Vector3(-view_direction.z, 0.0, view_direction.x)

	var center: Vector3 = player_position.lerp(boss_position, player_boss_position_ratio)
	center += view_direction * covered_by_healthbar * camera.size

	var next_position := Vector3(center.x + camera.offset_x, camera.global_position.y, center.z + camera.offset_z)
	camera.global_position = camera.global_position.lerp(next_position, 0.1)
	
	var height_component: float = direction.dot(view_direction)
	var offset_direction: Vector3 = (height_component * view_direction + direction).normalized()

	var player_offset: Vector3 = offset_direction * player_size
	var boss_offset: Vector3 = -offset_direction * boss_size

	var expanded_player_position: Vector3 = player_position + player_offset
	var expanded_boss_position: Vector3 = boss_position + boss_offset

	var connection_line: Vector3 = expanded_player_position - expanded_boss_position
	var height: float = absf(connection_line.dot(view_direction))
	var width: float = absf(connection_line.dot(right_direction))
	var target_size: float = maxf(height, width / aspect_ratio)
	camera.size = lerpf(camera.size, maxf(target_size, min_size), 0.1)


func _get_healthbar_height() -> float:
	if not _boss:
		return 0.0

	for child in _boss.get_children():
		if child is StatusVisualsEnemy:
			return child._get_overlay_bar_size().y
	
	return 0.0
