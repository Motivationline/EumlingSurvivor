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
@export var target_strategy: TargetStrategy
@export var rotation_strategy: RotationStrategy

@export_category("Multi Burst")
@export var time_between_bursts: float = 0
@export var amount_of_bursts: int = 1

func spawn(_relative_to: Node3D, _as_child_of: Node3D):
	for b in amount_of_bursts:
		if (b != 0 && time_between_bursts > 0):
			await get_tree().create_timer(time_between_bursts).timeout
		await burst(_relative_to, _as_child_of)
	
	spawn_finished.emit()

func burst(_relative_to: Node3D, _as_child_of: Node3D):
	for i in amount_of_spawns:
		if (i != 0 && time_between_entities > 0):
			await get_tree().create_timer(time_between_entities).timeout
		spawn_entity(_relative_to, _as_child_of, i, amount_of_spawns)
	burst_finished.emit()

func spawn_entity(_relative_to: Node3D, _as_child_of: Node3D, _current: int, _total: int):
		var instance = entity_to_spawn.instantiate() as Node3D
		_as_child_of.add_child(instance)
		
		instance.global_position = _relative_to.global_position
		instance.rotation = _relative_to.global_rotation
		if (target_strategy): 
			var target_position = target_strategy.get_target_position(_relative_to)
			target_position.y = _relative_to.global_position.y
			instance.look_at(target_position)
		if (rotation_strategy): rotation_strategy.apply_rotation(instance, _current, _total)

		instance.translate(Vector3.FORWARD * offset_distance)

		if (instance is Projectile):
			instance.setup(
				target_strategy.get_target_position(_relative_to) if (target_strategy) else _relative_to.global_position + basis.z
			)
