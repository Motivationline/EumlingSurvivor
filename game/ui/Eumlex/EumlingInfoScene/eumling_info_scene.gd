extends Node3D

var scenes: Array

func _ready() -> void:
	scenes = %Scenes.get_children()

func switch_scene(_index:int):
	for i in 5:
		if _index == i:
			scenes[i].show()
		else:
			scenes[i].hide()
			
