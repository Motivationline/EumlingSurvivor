extends EnemyMovementStrategy
class_name RandomEnemyMovementStrategy

@export var speed: float = 1
@export var wait_time: float = 1
# TODO add area inside of which the random values can be picked.

@export_category("Debug")
@export var debug_show_path: bool

var nav_agent: NavigationAgent3D

func _setup(_attached_to: Node):
	super._setup(_attached_to)
	nav_agent = NavigationAgent3D.new()
	add_child(nav_agent)
	nav_agent.navigation_finished.connect(target_reached)
	nav_agent.debug_enabled = debug_show_path
	find_new_target()

func get_movement_direction(old_direction: Vector3) -> Vector3:
	if (nav_agent.is_navigation_finished()): return old_direction
	var destination = nav_agent.get_next_path_position()
	var local_destination = destination - parent.global_position
	var direction = local_destination.normalized()
	return old_direction + direction * speed

func find_new_target():
	var random_position := Vector3.ZERO
	random_position.x = randf_range(-10, 10)
	random_position.z = randf_range(-10, 10)
	nav_agent.target_position = random_position
	#print(random_position)

func target_reached():
	await get_tree().create_timer(wait_time).timeout
	find_new_target()
