extends Node3D

const GAME = preload("uid://bck4sy6x58mj2")
var game: Game = GAME.instantiate()
const EUMLINGCLOPEDIA = preload("uid://ba2ayes40wtdh")
var eumlingclopedia = EUMLINGCLOPEDIA.instantiate()

# func _ready() -> void:
# 	eumlingclopedia.unlocked_eumling.connect(update_eumlex_number)

func _enter_tree() -> void:
	update_eumlex_number()

func update_eumlex_number():
	if Data._unlocked_eumlings.size() > 0:
		%NumberCircleLabel3D.text = str(Data._unlocked_eumlings.size())
		%NumberCircleLabel3D.get_parent().show()
	else:
		%NumberCircleLabel3D.get_parent().hide()

func _on_play_button_pressed() -> void:
	Main.controller.load_scene(game, false)
	game.start_new_run()

func _on_continue_button_pressed() -> void:
	Main.controller.load_scene(game, false)
	# TODO someone should really clean up the whole "save run and continue" logic.
	game.continue_run()

func _on_eumlex_button_pressed() -> void:
	if eumlingclopedia.get_parent() != self:
		add_child(eumlingclopedia)
	eumlingclopedia.show()
	eumlingclopedia.update_buttons()
	await eumlingclopedia.visibility_changed
	update_eumlex_number()
	# eumlingclopedia.unlock_new_eumlings(Data._unlocked_mini_eumlings)
	# SaveData.set_data("unlocked_mini_eumlings", Data._unlocked_mini_eumlings)
