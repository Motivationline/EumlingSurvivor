@tool
extends Node3D

@export var particles:Array[PackedScene]

func spawn_particles():
	for part in particles:
		var p = part.instantiate()
		add_child(p)
