@icon("spawner.svg")
extends Node3D
class_name EntitySpawner

signal burst_finished
signal spawn_finished


@export_category("Burst")
@export var entity_to_spawn: PackedScene
@export var amount_of_spawns: int = 1
@export var time_between_entities: float = 0
@export var offset_distance: float = 0

@export_category("Targeting")
@export var rotation_strategy: RotationStrategy
@export var target_strategy: TargetStrategy

@export_category("Multi Burst")
@export var time_between_bursts: float = 0
@export var amount_of_bursts: int = 1

func spawn(_parent: Node3D):
	for b in amount_of_bursts:
		if (b != 0 && time_between_bursts > 0):
			await get_tree().create_timer(time_between_bursts).timeout
		await burst(_parent)
	
	spawn_finished.emit()

func burst(_parent: Node3D):
	for i in amount_of_spawns:
		if (i != 0 && time_between_entities > 0):
			await get_tree().create_timer(time_between_entities).timeout
		spawn_entity(_parent, i, amount_of_spawns)
	burst_finished.emit()

func spawn_entity(_parent: Node3D, _current: int, _total: int):
		var instance = entity_to_spawn.instantiate() as Node3D
		_parent.add_child(instance)
		
		instance.global_position = global_position
		instance.rotation = target_strategy.get_target_direction(self) if (target_strategy) else global_rotation
		if (rotation_strategy): rotation_strategy.apply_rotation(instance, _current, _total)

		instance.translate(Vector3.FORWARD * offset_distance)

		if (instance is Projectile):
			instance.setup(
				target_strategy.get_target_position(self) if (target_strategy) else global_position + basis.z
			)
