extends Camera3D
@export var player: CharacterBody3D

var offset_x = 0.0
var offset_z = 0.0

func _ready() -> void:
	player = get_tree().get_nodes_in_group("Player")[0]
	offset_x =position.x
	offset_z =position.z
func _process(_delta: float) -> void:
	pass
func _physics_process(_delta: float) -> void:
	if player != null:
		global_position.x = lerp(global_position.x,player.global_position.x +offset_x,0.1)
		global_position.z = lerp(global_position.z,player.global_position.z + offset_z,0.1)
