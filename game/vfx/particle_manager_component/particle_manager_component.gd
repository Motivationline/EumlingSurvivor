extends Node
@export var kill_time: float  = 1.0
@export var particles_to_start: Array[GPUParticles3D]
@export var node_to_kill: Node

var timer: Timer

func _ready() -> void:
	for particles in particles_to_start:
		particles.emitting = true
	timer = Timer.new()
	timer.connect("timeout", node_to_kill.queue_free)
	add_child(timer)
	timer.start(kill_time)
	
	
	
