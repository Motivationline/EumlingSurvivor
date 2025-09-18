extends Node3D

var player_scene: PackedScene = preload("res://game/player/player.tscn")
var player: Player
@onready var level_wrapper: Node3D = $Level
@onready var scene_fade_animation_player: AnimationPlayer = $SceneFadeOverlay/AnimationPlayer
@onready var upgrade_view: CanvasLayer = $UpgradeView

func _ready() -> void:
	player = player_scene.instantiate()
	add_child(player)
	# init player here.
	load_level(choose_next_level())

var current_level: int = 0
func choose_next_level() -> String:
	current_level += 1
	var level_string = str(current_level).pad_zeros(3)
	return level_string

func load_level(level_id: String):
	scene_fade_animation_player.play("fade")
	await scene_fade_animation_player.animation_finished

	# remove old stuff
	var children = level_wrapper.get_children()
	for child in children:
		child.queue_free()
	
	# add new stuff
	assert(ResourceLoader.exists("res://game/levels/%s.tscn" % level_id))
	var level_to_load = load("res://game/levels/%s.tscn" % level_id) as PackedScene
	if (level_to_load && level_to_load.can_instantiate()):
		var new_level = level_to_load.instantiate() as Level
		level_wrapper.add_child(new_level)
		new_level.spawn_player(player)
		new_level.level_ended.connect(level_ended)
	
	scene_fade_animation_player.play_backwards("fade")

func level_ended():
	load_level(choose_next_level())

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("upgrade"):
		upgrade_view.show_upgrades(player)
