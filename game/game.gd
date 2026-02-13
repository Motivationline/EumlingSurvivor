extends Node3D
class_name Game

var player_scene: PackedScene = preload("res://game/player/player.tscn")
var player: Player
@onready var level_wrapper: Node3D = $Level
@onready var scene_fade_animation_player: AnimationPlayer = $SceneFadeOverlay/AnimationPlayer
@onready var upgrade_view: CanvasLayer = $UpgradeView
@onready var area_choice_overlay: Control = $AreaChoiceOverlay/AreaPicker
@onready var touch_joystick_overlay: CanvasLayer = $TouchJoystickOverlay

@onready var debug_upgrade_view: CanvasLayer = $DebugUpgradeView

signal requestMusic

var faded_to_black: bool = true
var levels_to_load: Array[String] = []

func _ready() -> void:
	player = player_scene.instantiate()
	add_child(player)
	# init player here.
	player.died.connect(return_to_main_menu)
	requestMusic.emit(false, MusicPlayer.LEVEL.MENU)
	# remove mobile overlay if not on mobile
	if not Data.is_on_mobile:
		touch_joystick_overlay.queue_free()

var currently_loaded_level: Level

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
	
	Engine.time_scale = 0
	var level_location: String = ""
	if !levels_to_load.size() > 0:
		area_choice_overlay.setup()
		levels_to_load = await area_choice_overlay.area_chosen
	level_location = levels_to_load.pop_front()


	# add new stuff
	var level_to_load = load(level_location) as PackedScene
	if (level_to_load && level_to_load.can_instantiate()):
		var new_level = level_to_load.instantiate() as Level
		level_wrapper.add_child(new_level)
		new_level.spawn_player(player)
		new_level.level_finished.connect(level_finished)
		new_level.level_ended.connect(level_ended)
		
		requestMusic.emit(false, new_level.music)

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
	scene_fade_animation_player.play("fade")
	await scene_fade_animation_player.animation_finished
	faded_to_black = true
	levels_to_load.clear()
	Data.active_mini_eumlings.clear()
	Main.controller.load_scene(Main.controller.main_menu, false)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("upgrade"):
		debug_upgrade_view.show_upgrades(player)
