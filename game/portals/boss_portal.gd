extends Node3D

signal entered

func _ready() -> void:
	$ExitArea.body_entered.connect(player_entered)

func player_entered(body: Node3D):
	if body == Player.player:
		entered.emit()
