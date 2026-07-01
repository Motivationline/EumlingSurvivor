extends Node3D

@export var minis: Dictionary[Enum.EUMLING_TYPE, PackedScene] = {}
@onready var mini_eumling_marker: Marker3D = $MiniEumling

func set_mini(type: Enum.EUMLING_TYPE):
	var mini_scene = minis.get(type)
	if mini_scene:
		Utils.remove_all_children(mini_eumling_marker)
		var mini_eumling = mini_scene.instantiate()
		mini_eumling_marker.add_child(mini_eumling)
