extends Node3D

@export var rotation_parent: Node3D
@onready var spawner = $EntitySpawner
@export var enabled: bool = false

func spawn_bullet():
	if enabled:
		spawner.spawn(self,rotation_parent)

func _on_attacktimer_timeout() -> void:
	spawn_bullet()
