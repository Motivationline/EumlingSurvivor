extends Node3D
@export var particles: Array[GPUParticles3D]
func _ready() -> void:
	$Sparkles.connect("finished",self.queue_free)
	for p in particles:
		p.emitting = true
