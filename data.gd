extends Node

var _unlocked_mini_eumlings: Array[Enum.EUMLING_TYPE] = []
var game_data: GameData
	
signal active_eumlings_changed(active_mini_eumlings: Array[Enum.EUMLING_TYPE])

func unlocked_eumling(type: Enum.EUMLING_TYPE):
	game_data.active_mini_eumlings.push_back(type)
	_unlocked_mini_eumlings.push_back(type)
	active_eumlings_changed.emit(game_data.active_mini_eumlings)
	SaveData.set_data("unlocked_mini_eumlings", _unlocked_mini_eumlings)

func add_upgrade_to_path(type: Enum.EUMLING_TYPE):
	var amount: int = game_data.upgrade_path_progress.get(type, 0)
	game_data.upgrade_path_progress.set(type, amount + 1)
	game_data.total_upgrades += 1

func end_game():
	game_data.reset()
	game_data.save()
	active_eumlings_changed.emit(game_data.active_mini_eumlings)


var is_on_mobile: bool = false

func _ready() -> void:
	is_on_mobile = OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios")
	var data = SaveData.get_data("unlocked_mini_eumlings", [] as Array[Enum.EUMLING_TYPE])
	for num in data:
		_unlocked_mini_eumlings.append(num)
	game_data = GameData.new() # has to happen here and not at var definition for order reasons
