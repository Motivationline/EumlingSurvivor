extends Node
class_name GameController

const MAIN_MENU = preload("res://game/ui/main_menu/main_menu.tscn")
var loading_screen: PackedScene = preload("uid://d2kq1cxqiwbkm")

var main_menu: Node3D
var delete_current_scene: bool

func _init() -> void:
	Main.controller = self

func load_main() -> void:
	main_menu = MAIN_MENU.instantiate()
	load_scene(main_menu, false)
	GlobalMusicManager.request_music(SongList.TRACK.TITLE, MusicTransition.instant())

func _clear(nodes_to_clear:Array[Node] = get_children()):
	for child in nodes_to_clear:
		if delete_current_scene:
			child.queue_free()
		else:
			remove_child(child)

func load_scene(node: Node, delete_scene_when_done: bool = false):
	var children = get_children()
	var new_loading_screen: LoadingScreen = loading_screen.instantiate()
	add_child(new_loading_screen)
	await new_loading_screen.loading_screen_ready
	_clear(children)
	delete_current_scene = delete_scene_when_done
	add_child(node)
	new_loading_screen._on_load_finished(null)

func load_game(game: Game, delete_scene_when_done: bool = false):
	var children = get_children()
	add_child(game)
	await game.level_loaded
	_clear(children)
	delete_current_scene = delete_scene_when_done
