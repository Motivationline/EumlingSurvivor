@tool
extends Node3D
class_name Level

## Where in the room the player is supposed to spawn
@export var player_spawn: Marker3D

## An area that when entered by a player after the complete condition is achieved, triggers a "level cleared" call
@export var goal_area: Area3D


@export var is_boss_level: bool = false

@export var music: MusicPlayer.LEVEL


var cleared: bool = false
var finished: bool = false
var ends: bool = false
var player: Player
const CAGED_MINI_EUMLING = preload("uid://6lim36lw260g")
const EUMLING_CELEBRATION = preload("uid://p83xt72cksyt")

## level done condition completed
signal level_cleared
## level visual completed, ready to end
signal level_finished
## player entered endzone, we're ending now.
signal level_ended

func _ready() -> void:
	if (Engine.is_editor_hint()):
		child_order_changed.connect(update_configuration_warnings)
		return
	add_to_group("Level")
	if (goal_area):
		goal_area.set_collision_mask_value(2, true)

var mini_eumlings: Array[MiniEumling] = []

func spawn_player(_player: Player):
	player = _player
	player.global_position = player_spawn.global_position
	player.global_rotation = player_spawn.global_rotation

	# spawn minis
	if not is_boss_level:
		for type in Data.active_mini_eumlings:
			var mini_eumling = MiniEumling.new()
			mini_eumling.type = type
			add_child(mini_eumling)
			mini_eumling.global_position = player_spawn.global_position
			mini_eumling.translate(Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)))
			mini_eumlings.push_back(mini_eumling)

func _process(_delta: float) -> void:
	if (Engine.is_editor_hint()): return
	if (!cleared):
		var enemies = get_tree().get_nodes_in_group("Enemy")
		if (enemies.size() <= 0):
			cleared = true
			level_cleared.emit()
			clear_level()
	if (finished && goal_area.overlaps_body(player) && !ends):
		ends = true
		if is_boss_level:
			await show_mini_popup()
		level_ended.emit()
		prints("level ended", name)


func clear_level():
	player.end_of_level()
	for me in mini_eumlings:
		me.celebrate()
	
	# TODO: Do stuff that needs to be done before the level can be unloaded, like collecting all the xp / items or something
	if is_boss_level:
		var caged = CAGED_MINI_EUMLING.instantiate() as Node3D
		add_child(caged)
		caged.global_position = player_spawn.global_position
	await get_tree().create_timer(1).timeout

	level_finished.emit()
	finished = true

func show_mini_popup():
	var popup = EUMLING_CELEBRATION.instantiate()
	add_child(popup)
	Data.active_mini_eumlings.append(randi_range(0, 4))
	await get_tree().create_timer(2).timeout

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if (!player_spawn): warnings.append("You need to provide a player spawn point")
	if (!goal_area): warnings.append("You need to provide a Goal Area")
	return warnings
