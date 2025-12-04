extends GPUParticles3D
@export var player:Player


func _process(delta: float) -> void:
	if player.velocity.length() > 0:
		emitting = true
	else:
		emitting = false
