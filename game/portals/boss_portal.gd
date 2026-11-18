class_name BossPortal extends Node3D

@export var eumlings: Dictionary[Enum.EUMLING_TYPE, PackedScene]

signal entered

func _ready() -> void:
	$ExitArea.body_entered.connect(player_entered)

func setup(eumling_type: Enum.EUMLING_TYPE):
	var scene = eumlings.get(eumling_type).instantiate()
	$MiniEumlingParent.add_child(scene)
	
func player_entered(body: Node3D):
	if body == Player.player:
		GlobalMusicManager.fade_out(3,true)
		entered.emit()
