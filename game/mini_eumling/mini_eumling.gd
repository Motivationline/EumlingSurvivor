extends Node3D
class_name MiniEumling

static var _type_resources: Dictionary[Enum.EUMLING_TYPE, Resource] = {
	Enum.EUMLING_TYPE.ARTISTIC: preload("uid://xx1ogf8cudcr"),
	Enum.EUMLING_TYPE.CONVENTIONAL: preload("uid://bdx5nmy7mmesh"),
	Enum.EUMLING_TYPE.ENTERPRISING: preload("uid://w0h1g2ngldyl"),
	Enum.EUMLING_TYPE.INVESTIGATIVE: preload("uid://pywy6q2jhxwo"),
	Enum.EUMLING_TYPE.REALISTIC: preload("uid://ylf5tr1haxpu"),
	Enum.EUMLING_TYPE.SOCIAL: preload("uid://drn335i4omarh"),
}


static func get_instance_of_type(_type: Enum.EUMLING_TYPE) -> Node3D:
	return _type_resources.get(_type).instantiate() as Node3D

var type: Enum.EUMLING_TYPE = Enum.EUMLING_TYPE.ARTISTIC
var player: Player
var visuals: Node3D

func _ready() -> void:
	visuals = MiniEumling.get_instance_of_type(type)
	add_child(visuals)
	player = get_tree().get_first_node_in_group("Player")

func _process(_delta: float) -> void:
	if player:
		look_at(player.global_position)

func celebrate() -> void:
	var anim = Utils.find_first_animation_tree(visuals)
	# anim.play("mini_eumling_celebrate")
	anim.set("parameters/Transition/transition_request", "celebrate")
