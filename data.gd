extends Node

var game_data: GameData
var is_on_mobile: bool = false

func _ready() -> void:
	is_on_mobile = OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios")
	_setup_eumlings()
	game_data = GameData.new() # has to happen here and not at var definition for order reasons

func add_upgrade_to_path(type: Enum.EUMLING_TYPE):
	var amount: int = game_data.upgrade_path_progress.get(type, 0)
	game_data.upgrade_path_progress.set(type, amount + 1)
	game_data.total_upgrades += 1

func end_game():
	game_data.reset()
	game_data.save()
	active_eumlings_changed.emit(game_data.active_mini_eumlings)


#region Eumlings

signal active_eumlings_changed(active_mini_eumlings: Array[Enum.EUMLING_TYPE])
	
const EUMLING_PATH = "res://game/eumlings/"

var eumlings: Dictionary = {}
var _locked_eumlings: Dictionary = {}
var _unlocked_eumlings: Array = [] # Array[String] but it's set through SaveData = No Type Info
var _seen_eumlings: Array = [] # Array[String] but it's set through SaveData = No Type Info


func _setup_eumlings():
	for type in Enum.EUMLING_TYPE.values():
		eumlings.set(type, [])
		_locked_eumlings.set(type, [])

	_unlocked_eumlings = SaveData.get_data("unlocked_eumlings", []  )
	_seen_eumlings = SaveData.get_data("seen_eumlings", [] )
	_load_eumlings()

func _load_eumlings(current_path: String = ""):
	var path = EUMLING_PATH + current_path
	var files = DirAccess.get_files_at(path);
	for file in files:
		if (file.get_extension() == "remap"):
			file = file.replace(".remap", "")
		if (file.get_extension() == "tres"):
			var eumling = ResourceLoader.load(path + file) as Eumling
			eumlings.get(eumling.type).append(eumling)
			if _unlocked_eumlings.has(eumling.id):
				eumling.progress = Enum.EUMLING_UNLOCK_PROGRESS.UNLOCKED
			elif _seen_eumlings.has(eumling.id):
				eumling.progress = Enum.EUMLING_UNLOCK_PROGRESS.SEEN
			else:
				_locked_eumlings[eumling.type].append(eumling)
	var folders := DirAccess.get_directories_at(path)
	for folder in folders:
		_load_eumlings(current_path + folder + "/")


func unlocked_eumling(type: Enum.EUMLING_TYPE):
	game_data.active_mini_eumlings.push_back(type)
	active_eumlings_changed.emit(game_data.active_mini_eumlings)

	_unlock_eumling(type)

func _unlock_eumling(type: Enum.EUMLING_TYPE) -> Eumling:
	var types: Array[Enum.EUMLING_TYPE] = [
		Enum.EUMLING_TYPE.ARTISTIC,
		Enum.EUMLING_TYPE.CONVENTIONAL,
		Enum.EUMLING_TYPE.ENTERPRISING,
		Enum.EUMLING_TYPE.INVESTIGATIVE,
		Enum.EUMLING_TYPE.REALISTIC,
		Enum.EUMLING_TYPE.SOCIAL,
	]
	types.remove_at(types.find(type))
	types.shuffle()
	types.push_front(type)

	for t in types:
		if _locked_eumlings[t].size() > 0:
			var index = randi_range(0, _locked_eumlings[t].size() - 1)
			var eumling = _locked_eumlings[t].pop_at(index)
			eumling.progress = Enum.EUMLING_UNLOCK_PROGRESS.UNLOCKED
			_unlocked_eumlings.push_back(eumling.id)
			SaveData.set_data("unlocked_eumlings", _unlocked_eumlings)
			return eumling
	return null

func reveal_eumling(eumling: Eumling):
	var uIndex = _unlocked_eumlings.find(eumling.id)
	if uIndex >= 0: _unlocked_eumlings.remove_at(uIndex)
	_seen_eumlings.append(eumling.id)
	SaveData.set_data("seen_eumlings", _seen_eumlings)
	SaveData.set_data("unlocked_eumlings", _unlocked_eumlings)

func sort_eumlings():
	for category: Array in eumlings.values():
		category.sort_custom(_sort_eumlings)

func _sort_eumlings(a: Eumling, b: Eumling) -> int:
	var progress = a.progress - b.progress
	if progress > 0:
		return true
	elif progress < 0:
		return false
		
	return a.name.naturalnocasecmp_to(b.name) < 0

#endregion
