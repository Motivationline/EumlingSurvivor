extends Node3D
class_name Game

var player_scene: PackedScene = preload("res://game/player/player.tscn")
var player: Player
@onready var level_wrapper: Node3D = $Level
@onready var scene_fade_animation_player: AnimationPlayer = $SceneFadeOverlay/AnimationPlayer
@onready var upgrade_view: CanvasLayer = $UpgradeView
@onready var area_choice_overlay: Control = $AreaChoiceOverlay/AreaPicker
@onready var touch_joystick_overlay: CanvasLayer = $TouchJoystickOverlay

@onready var debug_view: CanvasLayer = $DebugView

#signal requestMusic

var faded_to_black: bool = true
var levels_to_load: Array = []

func _ready() -> void:
	player = player_scene.instantiate()
	add_child(player)
	# init player here.
	player.died.connect(return_to_main_menu)

	# remove mobile overlay if not on mobile
	if not Data.is_on_mobile:
		touch_joystick_overlay.queue_free()

var currently_loaded_level: Level
var currently_loaded_level_info: Dictionary

func load_level():
	if player.dead:
		return
	
	if not faded_to_black:
		scene_fade_animation_player.play("fade")
		await scene_fade_animation_player.animation_finished
		faded_to_black = true

	# remove old stuff
	var children = level_wrapper.get_children()
	for child in children:
		child.queue_free()
	
	if !levels_to_load.size() > 0:
		if Data._unlocked_mini_eumlings.size() >= 4:
			$AreaChoiceOverlay/GameCompleteOverlay.show()
			await get_tree().create_timer(3).timeout
			$AreaChoiceOverlay/GameCompleteOverlay.hide()
			return_to_main_menu()
			return
		area_choice_overlay.setup()
		levels_to_load = await area_choice_overlay.area_chosen
	Engine.time_scale = 0
	var level_info = levels_to_load.pop_front()
	var level_location: String = level_info.id
	var difficulty: int = level_info.difficulty
	$DebugView.set_lvl(level_location, difficulty)
	# add new stuff
	var level_to_load = load(level_location) as PackedScene
	if (level_to_load && level_to_load.can_instantiate()):
		currently_loaded_level_info = level_info
		var new_level = level_to_load.instantiate() as Level
		new_level.difficulty = difficulty
		level_wrapper.add_child(new_level)
		new_level.spawn_player(player)
		new_level.level_finished.connect(level_finished)
		new_level.level_ended.connect(level_ended)
		GlobalMusicManager.request_music(new_level.music, GlobalMusicManager.TRANSITIONS.FADE_AND_START, [4, 0])


		currently_loaded_level = new_level
	

	scene_fade_animation_player.play_backwards("fade")
	faded_to_black = false
	Engine.time_scale = 1

func level_finished():
	if not currently_loaded_level.is_boss_level:
		upgrade_view.show_upgrades(player.possible_upgrades)
		var chosen_upgrade = await upgrade_view.upgrade_chosen
		player.add_upgrade(chosen_upgrade)

func level_ended():
	load_level()

func return_to_main_menu():
	GlobalMusicManager.request_music(SongList.TRACK.MENU, GlobalMusicManager.TRANSITIONS.FADE_AND_START, [2, 0])
	if not faded_to_black:
		scene_fade_animation_player.play("fade")
		await scene_fade_animation_player.animation_finished
		faded_to_black = true
	levels_to_load.clear()
	Data.end_game()
	Main.controller.load_scene(Main.controller.main_menu, false)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_menu"):
		if not debug_view.visible:
			debug_view.show_upgrades(player)
		else:
			debug_view.close()
	if event.is_action_pressed("debug_main_menu"):
		player.health = 0
	if event.is_action_pressed("debug_reload"):
		levels_to_load.push_front(currently_loaded_level_info)
		load_level()
	if event.is_action_pressed("debug_kill_all"):
		var enemies := get_tree().get_nodes_in_group("Enemy")
		for enemy in enemies:
			enemy.health = 0
