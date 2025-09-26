extends Node

@export var node_to_connect: Node
@export var signal_to_connect: String
@export var animation_player: AnimationPlayer
@export var animation_to_play: String
## use this if node is not in current scene
@export var node_with_animationplayer: Node3D


func _ready() -> void:
	if node_to_connect != null and signal_to_connect != "":
		node_to_connect.connect(signal_to_connect,_play_animation)
	if node_with_animationplayer != null:
		animation_player = find_first_animation_tree(node_with_animationplayer)

func find_first_animation_tree(node: Node3D) -> AnimationPlayer:
	if (!node): return null
	for child in node.get_children():
		if (child is AnimationPlayer): return child
		if (child.get_child_count() > 0 && child is Node3D):
			var tree = find_first_animation_tree(child)
			if (tree && tree is AnimationPlayer): return tree
	return null

func _play_animation(_a = null, _b = null, _c = null, _d = null, _e = null, _f = null, _h = null):
	animation_player.play(animation_to_play)
