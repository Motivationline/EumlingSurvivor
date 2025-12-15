extends Node3D

var player_scene: PackedScene = preload("res://game/player/player.tscn")
var player: Player
@onready var level_wrapper: Node3D = $Level
@onready var scene_fade_animation_player: AnimationPlayer = $SceneFadeOverlay/AnimationPlayer
@onready var upgrade_view: CanvasLayer = $UpgradeView
@onready var level_choice_overlay: CanvasLayer = $LevelChoiceOverlay
@onready var area_choice_overlay: CanvasLayer = $AreaChoiceOverlay

signal requestMusic

var levels_to_load: Array[String] = []

func _ready() -> void:
	player = player_scene.instantiate()
	add_child(player)
	# init player here.
	player.died.connect(level_ended)
	load_level()
	requestMusic.emit(false, MusicPlayer.LEVEL.MENU)
	

var current_level: int = 0
func choose_next_level() -> String:
	current_level += 1
	var level_string = str(current_level).pad_zeros(3)
	return level_string

func load_level():
	scene_fade_animation_player.play("fade")
	await scene_fade_animation_player.animation_finished

	player.health = INF

	# remove old stuff
	var children = level_wrapper.get_children()
	for child in children:
		child.queue_free()
	
	Engine.time_scale = 0
	var level_location: String = ""
	if OS.has_feature("editor"):
		while (true):
			level_choice_overlay.setup()
			var level_id = await level_choice_overlay.level_chosen
			level_location = find_file(level_id + ".tscn", "res://game/levels")
			if (level_location != "" and ResourceLoader.exists(level_location)):
				break
			else:
				printerr("Level '%s.tscn' doesn't exist in '/game/levels/' or its subfolders. Try again." % level_id)
	else:
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
		new_level.level_ended.connect(level_ended)
		
		requestMusic.emit(false, new_level.music)
	

	scene_fade_animation_player.play_backwards("fade")
	Engine.time_scale = 1

func level_ended():
	load_level()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("upgrade"):
		upgrade_view.show_upgrades(player)

func find_file(file_name: String, folder_location: String = "res://game/levels") -> String:
	# TODO: this might break on exported builds, so this needs to be replaced with something else before release!
	var dir := DirAccess.open(folder_location)
	if dir == null:
		return ""
	var files := dir.get_files()
	if files.has(file_name):
		return folder_location + "/" + file_name
	
	var dirs := dir.get_directories()
	for d in dirs:
		var path = find_file(file_name, folder_location + "/" + d)
		if path != "":
			return path

	return ""
