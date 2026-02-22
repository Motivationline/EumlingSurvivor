@abstract class_name SoundEvent extends Node

@export var on_ready:bool = false


func _ready():
	if on_ready:
		start()

@abstract func start() -> void
