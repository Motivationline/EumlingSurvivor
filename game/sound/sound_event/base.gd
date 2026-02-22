@tool
@abstract class_name SoundEvent extends Node

@export var on_ready:bool = false
signal started
signal finished



func _ready():
	if on_ready:
		start()
	

@abstract func start() ->void
