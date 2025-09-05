extends Node
@export var kill_time: float  = 1.0
@export var node_to_kill: Node

var timer: Timer

func _ready() -> void:
	var particles_to_start = find_particles()
	for particles in particles_to_start:
		particles.emitting = true
	timer = Timer.new()
	timer.connect("timeout", node_to_kill.queue_free)
	add_child(timer)
	timer.start(kill_time)
	
func find_particles() -> Array:
	var particles: Array
	var children = get_parent().get_children()
	for child in children:
		if child is GPUParticles3D or child is CPUParticles3D:
			particles.append(child)
	return particles
