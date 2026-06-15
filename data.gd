extends Node

var _unlocked_mini_eumlings: Array[Enum.EUMLING_TYPE] = []
var _active_mini_eumlings: Array[Enum.EUMLING_TYPE] = [] # [Enum.EUMLING_TYPE.SOCIAL]
var _upgrade_path_progress: Dictionary[Enum.EUMLING_TYPE, int]
var total_upgrades: int = 0
	
signal active_eumlings_changed(active_mini_eumlings: Array[Enum.EUMLING_TYPE])

func unlocked_eumling(type: Enum.EUMLING_TYPE):
	_active_mini_eumlings.push_back(type)
	_unlocked_mini_eumlings.push_back(type)
	active_eumlings_changed.emit(_active_mini_eumlings)
	SaveData.set_data("unlocked_mini_eumlings", _unlocked_mini_eumlings)

func add_upgrade_to_path(type: Enum.EUMLING_TYPE):
	var amount: int = _upgrade_path_progress.get(type, 0)
	_upgrade_path_progress.set(type, amount + 1)
	total_upgrades += 1

func end_game():
	_active_mini_eumlings.clear()
	active_eumlings_changed.emit(_active_mini_eumlings)
	_upgrade_path_progress.clear()
	total_upgrades = 0


var is_on_mobile: bool = false

func _ready() -> void:
	is_on_mobile = OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios")
	var data = SaveData.get_data("unlocked_mini_eumlings", [] as Array[Enum.EUMLING_TYPE])
	for num in data:
		_unlocked_mini_eumlings.append(num)
