extends Node3D

const GAME = preload("uid://bck4sy6x58mj2")
var game: Game = GAME.instantiate()
const EUMLINGCLOPEDIA = preload("uid://ba2ayes40wtdh")
var eumlingclopedia = EUMLINGCLOPEDIA.instantiate()

func _on_play_button_pressed() -> void:
	Main.controller.load_scene(game, false)
	game.start_new_run()

func _on_continue_button_pressed() -> void:
	Main.controller.load_scene(game, false)
	# TODO someone should really clean up the whole "save run and continue" logic.
	game.continue_run()

func _on_eumlex_button_pressed() -> void:
	Main.controller.load_scene(eumlingclopedia, false)
	eumlingclopedia.unlock_new_eumlings(Data._unlocked_mini_eumlings)
	SaveData.set_data("unlocked_mini_eumlings", Data._unlocked_mini_eumlings)
