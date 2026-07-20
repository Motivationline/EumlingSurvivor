@tool
class_name FlockMovementController
extends Node3D
## Coordinates the flock.

var _parent: StateMachinePoweredEntity
var _navigation_agent := NavigationAgent3D.new()
var _flock_configuration := FlockMovementConfiguration.new():
	set(configuration):
		if configuration:
			_flock_configuration = configuration
		else:
			_flock_configuration = FlockMovementConfiguration.new()
		_navigation_agent.path_desired_distance = _flock_configuration.path_desired_distance
		_navigation_agent.target_desired_distance = _flock_configuration.target_desired_distance
		_navigation_agent.avoidance_enabled = _flock_configuration.avoidance_enabled
		_navigation_agent.radius = _flock_configuration.radius
		_navigation_agent.neighbor_distance = _flock_configuration.neighbor_distance
		_navigation_agent.max_neighbors = _flock_configuration.max_neighbors
		_navigation_agent.path_height_offset = ProjectSettings.get_setting("navigation/3d/default_cell_height", 0.25) * 2.0
		_navigation_agent.debug_enabled = _flock_configuration.debug_enabled
var _rotate_with_movement: bool = true


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	var parent_node: Node = get_parent()
	assert(parent_node is StateMachinePoweredEntity, name + " needs to be a child of a StateMachinePoweredEntity.")
	_parent = parent_node

	add_child(_navigation_agent)
	_navigation_agent.velocity_computed.connect(_move)


func enter_state(configuration: FlockMovementConfiguration) -> void:
	_flock_configuration = configuration
	_rotate_with_movement = true


func exit_state() -> void:
	move(Vector3.ZERO)
	# Prevent the entity from looking at the direction it might be getting pushed towards.
	_rotate_with_movement = false


func move(velocity: Vector3) -> void:
	if _navigation_agent.avoidance_enabled:
		_navigation_agent.velocity = velocity
	else:
		_move(velocity)


func set_target_position(target_position: Vector3) -> void:
	_navigation_agent.target_position = target_position


func is_navigation_finished() -> bool:
	return _navigation_agent.is_navigation_finished()


func get_next_path_position() -> Vector3:
	return _navigation_agent.get_next_path_position()


func _move(velocity: Vector3) -> void:
	_parent.velocity = velocity
	if "visuals" in _parent and not velocity.is_zero_approx() and _rotate_with_movement:
		_parent.visuals.rotation.y = atan2(-velocity.x, -velocity.z)
	_parent.move_and_slide()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PARENTED:
		update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if get_parent() is not StateMachinePoweredEntity:
		warnings.append("The Parent needs to be a StateMachinePoweredEntity.")
	return warnings
