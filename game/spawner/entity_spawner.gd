@icon("spawner.svg")
extends Node3D
class_name EntitySpawner

signal burst_finished
signal spawn_finished

## If set, spawns the entity as a child of the relevant parent, to the level otherwise. [color=red]Does not affect the position or rotation, only the parent[/color]
@export var spawn_local: bool = false

@export_category("Burst")
@export var entity_to_spawn: PackedScene
@export_range(0, 100) var amount_of_spawns: int = 1
@export_range(0, 60, 0.1) var time_between_entities: float = 0
@export var offset_distance: float = 0

@export_category("Targeting")
@export var target_strategy: TargetStrategy
@export var rotation_strategy: RotationStrategy

@export_category("Multi Burst")
@export_range(0, 60, 0.1) var time_between_bursts: float = 0
@export_range(0, 100) var amount_of_bursts: int = 1

func spawn(_parent: Node3D, _relative_to: Node3D = null):
	if (!_relative_to): _relative_to = _parent
	for b in amount_of_bursts:
		if (b != 0 && time_between_bursts > 0):
			await get_tree().create_timer(time_between_bursts).timeout
		await burst(_parent, _relative_to)
	
	spawn_finished.emit()

func burst(_parent: Node3D, _relative_to: Node3D):
	for i in amount_of_spawns:
		if (i != 0 && time_between_entities > 0):
			await get_tree().create_timer(time_between_entities).timeout
		spawn_entity(_parent, _relative_to, i, amount_of_spawns)
	burst_finished.emit()

func spawn_entity(_parent: Node3D, _relative_to: Node3D, _current: int, _total: int):
	if (!entity_to_spawn):
		printerr("%s attached to %s tried to spawn nothing" % [name, _parent.name])
		return
	var instance = entity_to_spawn.instantiate() as Node3D
	if (spawn_local): _parent.add_child(instance)
	else:
		var level = _parent.get_tree().get_nodes_in_group("Level")[0]
		if (level): level.add_child(instance)
		else:
			printerr("%s attached to %s tried to spawn on the level but level not found." % [name, _parent.name])
			return
	
	instance.global_position = _relative_to.global_position
	instance.global_rotation = _relative_to.global_rotation
	if (target_strategy):
		var target_position = target_strategy.get_target_position(_relative_to)
		target_position.y = _relative_to.global_position.y
		instance.look_at(target_position)
	if (rotation_strategy): rotation_strategy.apply_rotation(instance, _current, _total)

	instance.translate(Vector3.FORWARD * offset_distance)

	if (instance is Projectile):
		instance.setup(
			target_strategy.get_target_position(_relative_to) if (target_strategy) else _relative_to.global_position + _relative_to.basis.z
		)
