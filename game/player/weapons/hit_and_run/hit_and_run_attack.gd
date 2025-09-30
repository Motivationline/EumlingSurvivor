extends Node3D


@export var rotation_parent: Node3D
@onready var spawner = $EntitySpawner
@onready var timer= $attack_time
@export var player : Player
@export var enabled: bool = false



func spawn():
	if enabled:
		spawner.spawn(self,rotation_parent)

func _physics_process(delta: float) -> void:
	if player.velocity.length() <= 0.1 and timer.is_stopped():
		spawn()
		timer.start()
