extends Node3D

const GAME = preload("uid://bck4sy6x58mj2")
var game: Game = GAME.instantiate()
const EUMLINGCLOPEDIA = preload("uid://d0tttappajswp")
var eumlingclopedia = EUMLINGCLOPEDIA.instantiate()

func _on_play_button_pressed() -> void:
	Main.controller.load_scene(game, false)
	game.player.reset()
	game.load_level()

func _on_eumlingclopedia_button_pressed() -> void:
	Main.controller.load_scene(eumlingclopedia, false)
	eumlingclopedia.unlock_new_eumlings(Data.unlocked_mini_eumlings)
