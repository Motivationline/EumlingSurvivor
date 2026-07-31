@tool
class_name FlockTowardsEntityState
extends State
## Moves the entity towards the target. Coordinates with other entities to move as a flock.

## Coordinates the flock.
@export var flock_controller: FlockMovementController:
	set(controller):
		flock_controller = controller
		update_configuration_warnings()
## Settings for the flock.
@export var flock_configuration: FlockMovementConfiguration

@export_group("Overrides")
## Movement Speed Override
@export_range(0, 100, 0.1) var speed_override: float = 1.0:
	set(new_value):
		speed_override = maxf(new_value, 0.0)
## Whether to apply the speed override
@export var speed_override_active: bool = false

@export_category("Target Entity")
## Which entity group to find an entity to move towards
@export var entity_group: String = "Player"
## if set filters the group for an entity with this name. If unset, takes a random entity from the group
@export var entity_name: String = ""
## how to choose from a potential list of enemies 
@export var selection_strategy := Enum.SELECTION_STRATEGY.RANDOM

var target_entity: Node


func enter() -> void:
	super()

	flock_controller.enter_state(flock_configuration)

	target_entity = _find_target_entity()
	_update_target_position()


func physics_process(_delta: float) -> State:
	if flock_controller.is_navigation_finished():
		flock_controller.exit_state()
		return return_next()
	
	_update_target_position()
	var next_position: Vector3 = flock_controller.get_next_path_position()
	var direction: Vector3 = parent.global_position.direction_to(next_position)
	var speed: float = speed_override if speed_override_active else parent.speed

	flock_controller.move(direction * speed)

	return null


func _update_target_position() -> void:
	if is_instance_valid(target_entity):
		flock_controller.set_target_position(target_entity.global_position)
	else:
		flock_controller.set_target_position(parent.global_position)


func _find_target_entity() -> Node3D:
	var entities: Array[Node] = get_tree().get_nodes_in_group(entity_group)
	
	if not entity_name.is_empty():
		entities = entities.filter(func(node: Node) -> bool:
				return node.name == entity_name)

	if entities.is_empty():
		push_warning("Didn't find any entity in group '" + entity_group + "' (with name '" + entity_name + "' )")
		return null
	
	match selection_strategy:
		Enum.SELECTION_STRATEGY.NEAREST:
			Utils.sort_array_by_distance(entities, parent)
		Enum.SELECTION_STRATEGY.FURTHEST:
			Utils.sort_array_by_distance(entities, parent)
			entities.reverse()
		_:
			entities.shuffle()
	
	return entities[0] as Node3D


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = super()
	if not flock_controller:
		warnings.append("Assign a FlockMovementController.")
	return warnings
