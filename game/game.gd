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

func _ready() -> void:
	# connect to home signal
	$GameUI/PauseMenu.return_home.connect(return_to_main_menu)

	# remove mobile overlay if not on mobile
	if not Data.is_on_mobile:
		touch_joystick_overlay.queue_free()
	area_choice_overlay.hide()

var currently_loaded_level: Level
var currently_loaded_level_info: Dictionary

func continue_run():
	Data.game_data.reload()
	_setup_player()
	player._current_values = Data.game_data.player_upgrades.duplicate()
	player.health = Data.game_data.player_health
	_load_level()

func start_new_run():
	Data.game_data.reset()
	_setup_player()
	_load_level()

func _setup_player():
	if (player):
		player.queue_free()
	player = player_scene.instantiate()
	add_child(player)
	player.died.connect(end_run)

func _load_level():
	if player.dead:
		return
	
	if not faded_to_black:
		scene_fade_animation_player.play("fade")
		await scene_fade_animation_player.animation_finished
		faded_to_black = true

	# remove old stuff
	Utils.remove_all_children(level_wrapper)
	
	if !Data.game_data.levels_to_load.size() > 0:
		if Data.game_data.difficulty >= 4:
			$AreaChoiceOverlay/GameCompleteOverlay.show()
			await get_tree().create_timer(3).timeout
			$AreaChoiceOverlay/GameCompleteOverlay.hide()
			end_run()
			return
		area_choice_overlay.setup()
		GlobalMusicManager.request_music(SongList.TRACK.MENU, MusicTransition.fade_and_start(2,0))
		Data.game_data.levels_to_load = await area_choice_overlay.area_chosen

	var stage_progress = Data.game_data.difficulty + 4
	%BaseBattleOverlay.update_visuals(stage_progress, Data.game_data.levels_to_load.size())

	Engine.time_scale = 0
	var level_info = Data.game_data.levels_to_load.pop_front()
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
		GlobalMusicManager.request_music(new_level.music, MusicTransition.fade_and_start(4,0))


		currently_loaded_level = new_level
	

	scene_fade_animation_player.play_backwards("fade")
	faded_to_black = false
	Engine.time_scale = 1

func level_finished():
	if not currently_loaded_level.is_boss_level:
		upgrade_view.show_upgrades()
		var chosen_upgrade: Upgrade = await upgrade_view.upgrade_chosen
		player.add_upgrade(chosen_upgrade)
		display_big_update(chosen_upgrade)

	player.level_completed(currently_loaded_level)
	save_game_data()

func display_big_update(upgrade: Upgrade) -> void:
	var progress = Data.game_data.upgrade_path_progress.get(upgrade.path, 0)
	var progress_steps: Array[int] = [3, 6, 9]
	if not progress_steps.has(progress): return
	%MilestoneUpgrade.setup(upgrade.path, progress_steps.find(progress))
	await %MilestoneUpgrade.done


func save_game_data():
	Data.game_data.player_upgrades = player._current_values
	Data.game_data.player_health = player.health
	Data.game_data.save()

func level_ended():
	_load_level()

func end_run():
	Data.end_game()
	return_to_main_menu()

func return_to_main_menu():
	GlobalMusicManager.request_music(SongList.TRACK.MENU, MusicTransition.fade_and_start(2,0))
	if not faded_to_black:
		scene_fade_animation_player.play("fade")
		await scene_fade_animation_player.animation_finished
		faded_to_black = true
	Main.controller.load_scene(Main.controller.main_menu, false)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_menu"):
		if not debug_view.visible:
			debug_view.show_upgrades()
		else:
			debug_view.close()
	if event.is_action_pressed("debug_main_menu"):
		player.health = 0
	if event.is_action_pressed("debug_reload"):
		Data.game_data.levels_to_load.push_front(currently_loaded_level_info)
		_load_level()
	if event.is_action_pressed("debug_kill_all"):
		var enemies := get_tree().get_nodes_in_group("Enemy")
		for enemy in enemies:
			enemy.health = 0
	if event.is_action_pressed("debug_get_upgrade"):
		upgrade_view.show_upgrades()
		var chosen_upgrade = await upgrade_view.upgrade_chosen
		player.add_upgrade(chosen_upgrade)
		display_big_update(chosen_upgrade)
