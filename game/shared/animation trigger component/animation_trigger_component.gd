extends Node

@export var node_to_connect: Node
@export var signal_to_connect: String
@export var animation_player: AnimationPlayer
@export var animation_to_play: String


func _ready() -> void:
	if node_to_connect != null and signal_to_connect != "":
		var signal_list = node_to_connect.get_signal_list()
		for sig in signal_list:
			print(sig.get("args",[]))
	
