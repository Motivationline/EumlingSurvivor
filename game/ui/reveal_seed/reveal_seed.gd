extends Node3D

var mini_eumling:Array[Node]
@export_range(0,5) var which_eumling_is_shown: int
func _ready() -> void:
	mini_eumling = $Mini_Eumling_Anchor.get_children()
	
func _show_eumling(_index:int):
	if mini_eumling==null:return
	for i in 5:
		if i == _index:
			mini_eumling[i].show()
		else:
			mini_eumling[i].hide()
	
func prepare():
	_show_eumling(which_eumling_is_shown)
