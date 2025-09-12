extends Node3D

@export var weapon: PackedScene

@export var weapon_name: String = ""

func _ready() -> void:
	$Label3D.text = weapon_name

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		var player = get_tree().get_nodes_in_group("Player")[0]
		switch_weapon(player)

func switch_weapon(_player:Player):
	_player.spawner.entity_to_spawn = weapon
