@tool
class_name SpawnerLinker extends Node
##Attach to an [EntitySpawner] to link the spawned entities to the spawner. Linked entities will be destroyed if the spawner is destroyed.

var spawner:EntitySpawner
var spawned_entities:Array[Node3D]

func _ready():
	if get_parent() is EntitySpawner:
		spawner = get_parent()
		spawner.entity_spawned.connect(_on_entity_spawned)
		spawner.tree_exited.connect(_on_spawner_freed)

func _get_configuration_warnings():
	if not get_parent() is EntitySpawner:
		return ["Must be child of an EntitySpawner node!"]
	return []


func _on_entity_spawned(_spawned_entity:Node3D) -> void:
	spawned_entities.push_back(_spawned_entity)



func _on_spawner_freed() -> void:
	for entity in spawned_entities:
		if entity:
			if entity is Enemy:
				entity._die()
			else:
				entity.queue_free()
