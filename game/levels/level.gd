@tool
extends Node3D
class_name Level


## Where in the room the player is supposed to spawn
@export var player_spawn: Marker3D

## An area that when entered by a player after the complete condition is achieved, triggers a "level cleared" call
@export var goal_area: Area3D

@export var is_boss_level: bool = false
@export var portal_positions: Array[Marker3D]

@export var music: SongList.TRACK = SongList.TRACK.MENU


enum LEVEL_STATE {
	PLAYING,
	CLEARED,
	CAGE_SPAWNED,
	FINISHED,
	ENDING,
}

var difficulty: int
var state: LEVEL_STATE
var player: Player

const CAGED_MINI_EUMLING = preload("uid://6lim36lw260g")
const EUMLING_CELEBRATION = preload("uid://p83xt72cksyt")
const MINI_EUMLING_E = preload("uid://cd212gh71k5cn")
const MINI_EUMLING_R = preload("uid://ecxm5futmmj4")

var PORTALS = [load("uid://css0jedfj0qmt"), load("uid://c5d58pjp1p4bh"), load("uid://bk5prj6enj3k8")]


## it's a boss level and the cage has been spawned
signal cage_spawned
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
	state = LEVEL_STATE.PLAYING

func spawn_player(_player: Player):
	player = _player
	player.global_position = player_spawn.global_position
	player.global_rotation = player_spawn.global_rotation

	# spawn minis
	for type in Data.game_data.active_mini_eumlings:
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
	if (state == LEVEL_STATE.PLAYING):
		var enemies = get_tree().get_nodes_in_group("Enemy")
		if (enemies.size() <= 0):
			if is_boss_level:
				spawn_cage()
			else:
				clear_level()
	if (state == LEVEL_STATE.CAGE_SPAWNED && goal_area.overlaps_body(player)):
		clear_level()
	if (state == LEVEL_STATE.FINISHED && goal_area.overlaps_body(player) && not is_boss_level):
		end_level()

var caged_eumling
func spawn_cage():
	state = LEVEL_STATE.CAGE_SPAWNED
	caged_eumling = CAGED_MINI_EUMLING.instantiate() as Node3D
	add_child(caged_eumling)
	caged_eumling.global_position = player_spawn.global_position
	cage_spawned.emit()

func clear_level():
	state = LEVEL_STATE.CLEARED
	level_cleared.emit()
	if is_boss_level:
		await unlock_mini_eumling()
	await get_tree().create_timer(1).timeout

	level_finished.emit()
	state = LEVEL_STATE.FINISHED
	
	if is_boss_level:
		spawn_portals_or_end()

func spawn_portals_or_end():
	if Data.game_data.difficulty < 4:
		spawn_portals()
	else:
		end_level()


func spawn_portals():
	for p_index in PORTALS.size():
		if portal_positions.size() < p_index: break
		var portal = PORTALS[p_index].instantiate() as Node3D
		var pos = portal_positions[p_index]
		add_child(portal)
		portal.global_position = pos.global_position
		portal.global_rotation = pos.global_rotation
		portal.entered.connect(entered_portal.bind(p_index))

func entered_portal(id: int):
	Data.game_data.levels_to_load = AreaPicker.choose_area_levels_from_index(id)
	end_level()


func end_level():
	state = LEVEL_STATE.ENDING
	level_ended.emit()
	prints("level ended", name)

func unlock_mini_eumling():
	remove_child(caged_eumling)
	var eumling_type: Enum.EUMLING_TYPE
	if AreaPicker.current_area:
		eumling_type = AreaPicker.current_area.type
	else:
		eumling_type = Enum.EUMLING_TYPE.values().pick_random()
	Data.unlocked_eumling(eumling_type)
	var popup = EUMLING_CELEBRATION.instantiate()
	popup.find_child("Label").text = "%s eumling has been rescued! Yay!" % Enum.EUMLING_TYPE.keys()[eumling_type]
	add_child(popup)
	await get_tree().create_timer(2).timeout
	remove_child(popup)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if (!player_spawn): warnings.append("You need to provide a player spawn point")
	if (!goal_area): warnings.append("You need to provide a Goal Area")
	if (is_boss_level && portal_positions.size() < 3): warnings.append("A boss level needs to define at least 3 portal positions")
	return warnings
