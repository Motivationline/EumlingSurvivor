extends Camera3D
@export var player: CharacterBody3D

var offset_x = 0.0
var offset_z = 0.0

func _ready() -> void:
	offset_x = position.x
	offset_z = position.z
func _process(delta: float) -> void:
	pass
func _physics_process(delta: float) -> void:
	global_position.x = lerp(global_position.x,player.global_position.x +offset_x,0.1)
	global_position.z = lerp(global_position.z,player.global_position.z + offset_z,0.1)
