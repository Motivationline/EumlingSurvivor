extends Node3D

@export var enabled: bool = false
@export var rotation_parent: Node3D
@onready var entity_spawner: EntitySpawner = $EntitySpawner
@onready var timer: Timer = $Timer

func try_to_shoot() -> bool:
	if not enabled: return false
	if not timer.is_stopped(): return false
	entity_spawner.spawn(self, rotation_parent)
	timer.start()
	return true
