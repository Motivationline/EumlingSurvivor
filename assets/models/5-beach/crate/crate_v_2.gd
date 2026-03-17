extends Node3D

func _ready() -> void:
	await get_tree().create_timer(randf_range(0.0,1.0)).timeout
	$AnimationPlayer.play("swim")
