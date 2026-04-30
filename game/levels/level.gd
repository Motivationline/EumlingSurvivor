@tool
extends Node3D
class_name Level


## Where in the room the player is supposed to spawn
@export var player_spawn: Marker3D

## An area that when entered by a player after the complete condition is achieved, triggers a "level cleared" call
@export var goal_area: Area3D

@export var is_boss_level: bool = false

@export var music:SongList.TRACK = SongList.TRACK.MENU

var difficulty: int
var cleared: bool = false
var finished: bool = false
var ends: bool = false
var player: Player

const CAGED_MINI_EUMLING = preload("uid://6lim36lw260g")
const EUMLING_CELEBRATION = preload("uid://p83xt72cksyt")
const MINI_EUMLING_E = preload("uid://cd212gh71k5cn")
const MINI_EUMLING_R = preload("uid://ecxm5futmmj4")

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

func spawn_player(_player: Player):
	player = _player
	player.global_position = player_spawn.global_position
	player.global_rotation = player_spawn.global_rotation

	# spawn minis
	for type in Data._active_mini_eumlings:
		spawn_mini_eumling(type)
	
	player.level_start()

func spawn_mini_eumling(type: Enum.EUMLING_TYPE):
	# only spawn minis that need to follow player
	var mini_eumling
	if type == Enum.EUMLING_TYPE.ENTERPRISING:
		mini_eumling = MINI_EUMLING_E.instantiate()
	elif type == Enum.EUMLING_TYPE.REALISTIC:
		mini_eumling = MINI_EUMLING_R.instantiate()

	if mini_eumling:
		add_child(mini_eumling)
		mini_eumling.global_position = player_spawn.global_position
		mini_eumling.translate(Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)))

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
	player.level_completed(self)
	# for me in mini_eumlings:
	# 	me.celebrate()
	
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
	Data.unlocked_eumling([Enum.EUMLING_TYPE.SOCIAL, Enum.EUMLING_TYPE.INVESTIGATIVE, Enum.EUMLING_TYPE.ARTISTIC, Enum.EUMLING_TYPE.CONVENTIONAL, Enum.EUMLING_TYPE.ENTERPRISING].pick_random())
	await get_tree().create_timer(2).timeout

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if (!player_spawn): warnings.append("You need to provide a player spawn point")
	if (!goal_area): warnings.append("You need to provide a Goal Area")
	return warnings
