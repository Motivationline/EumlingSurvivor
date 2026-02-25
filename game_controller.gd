extends Node
class_name GameController

const MAIN_MENU = preload("res://game/ui/main_menu/main_menu.tscn")

var main_menu: Node3D
var delete_current_scene: bool

func _init() -> void:
	Main.controller = self

func _ready() -> void:
	main_menu = MAIN_MENU.instantiate()
	load_scene(main_menu, false)
	GlobalMusicManager.request_music(SongList.TRACK.MENU,GlobalMusicManager.TRANSITIONS.INSTANT)

func _clear():
	for child in get_children():
		if delete_current_scene:
			child.queue_free()
		else:
			remove_child(child)

func load_scene(node: Node, delete_scene_when_done: bool = false):
	_clear()
	delete_current_scene = delete_scene_when_done
	add_child(node)
