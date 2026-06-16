class_name GameData extends RefCounted

var player_health: float = 100
var player_upgrades: Dictionary[Enum.UPGRADE, float] = {}
var total_upgrades: int = 0
var active_mini_eumlings: Array[Enum.EUMLING_TYPE] = []
var upgrade_path_progress: Dictionary[Enum.EUMLING_TYPE, int]
var levels_to_load: Array = []
var difficulty: int:
	get():
		return active_mini_eumlings.size()


func _init() -> void:
	reload()

func reload() -> void:
	player_health = 1000000
	player_upgrades.clear()
	active_mini_eumlings.clear()
	upgrade_path_progress.clear()
	levels_to_load.clear()
	total_upgrades = 0
	
	var data = SaveData.get_data("game_data")
	if not data: return
	if data.has("player_health"): player_health = data.player_health
	if data.has("player_upgrades"): 
		for key in data.player_upgrades.keys():
			player_upgrades.set(int(key), data.player_upgrades[key])
	if data.has("total_upgrades"): total_upgrades = data.total_upgrades
	if data.has("active_mini_eumlings"):
		for e in data.active_mini_eumlings: 
			active_mini_eumlings.append(e)
	if data.has("upgrade_path_progress"): 
		for key in data.upgrade_path_progress.keys():
			upgrade_path_progress.set(int(key), data.upgrade_path_progress[key]) 
	if data.has("levels_to_load"): 
		for level in data.levels_to_load:
			levels_to_load.append(level)


func save():
	SaveData.set_data("game_data",
		{
			"player_health": player_health,
			"player_upgrades": player_upgrades.duplicate(),
			"total_upgrades": total_upgrades,
			"active_mini_eumlings": active_mini_eumlings.duplicate(),
			"upgrade_path_progress": upgrade_path_progress.duplicate(),
			"levels_to_load": levels_to_load.duplicate(),
		}
	)

func get_eumling_amount(type: Enum.EUMLING_TYPE) -> int:
	return active_mini_eumlings.count(type)

func reset():
	active_mini_eumlings.clear()
	upgrade_path_progress.clear()
	total_upgrades = 0
	levels_to_load.clear()
