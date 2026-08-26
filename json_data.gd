extends Node

const UPGRADE_VALUES = "res://game/upgrade/upgrade_values.json"
const SPECIAL_UPGRADES = "res://game/upgrade/special_upgrades.json"

var player_upgrade_levels: Dictionary = {}
var player_special_upgrades: Dictionary[Enum.EUMLING_TYPE, Array] = {}

func _ready():
	_load_upgrades()

func _load_upgrades():
	var raw_upgrades = _load_json_file(UPGRADE_VALUES).upgrade_values
	if not raw_upgrades is Dictionary:
		printerr("Upgrade values JSON not in expected format!")
		return
	
	var player_upgrade_info: Dictionary = {}
	for key in raw_upgrades.get("Method"):
		player_upgrade_info.set(key, {method = Enum.UPGRADE_METHOD.ABSOLUTE if raw_upgrades.get("Method").get(key) == "Additiv" else Enum.UPGRADE_METHOD.MULTIPLIER})
	for key in raw_upgrades.get("Text"):
		var text = raw_upgrades.get("Text").get(key)
		if not text: text = "%s"
		player_upgrade_info.get(key).set("text", text)
	for key in raw_upgrades.get("Display_Faktor"):
		var value = raw_upgrades.get("Display_Faktor").get(key)
		if not value: value = 1
		player_upgrade_info.get(key).set("display_factor", value)

	for key in raw_upgrades.keys():
		if key.is_valid_int():
			var level: int = int(key)
			var upgrades: Array[Upgrade] = []
			var level_upgrades: Dictionary = raw_upgrades.get(key)
			for type in level_upgrades.keys():
				var info = player_upgrade_info.get(type)
				var value = level_upgrades.get(type)
				if not value: continue
				upgrades.append(Upgrade.new(Enum.UPGRADE.keys().find(type), info.method, value, info.text, info.display_factor))
			player_upgrade_levels.set(level, upgrades)
	
	
	var raw_special_upgrades = _load_json_file(SPECIAL_UPGRADES).special_upgrades
	if not raw_special_upgrades is Array:
		printerr("Special Upgrades JSON not in expected format")
	
	for upgrade in raw_special_upgrades:
		if not upgrade.has("type"): continue
		var type = Enum.EUMLING_TYPE.keys().find((upgrade.path as String).to_upper())
		if type == null: continue
		var type_array: Array = player_special_upgrades.get_or_add(type, [])
		var index: int = int(upgrade.group);
		if type_array.size() <= index:
			type_array.resize(index + 1)
		if not type_array[index]:
			type_array[index] = []
		var key = Enum.UPGRADE.keys().find(upgrade.type)
		var info = player_upgrade_info.get(upgrade.type)
		type_array[index].append(Upgrade.new(
			Enum.UPGRADE.DONT_COUNT, # TODO: this is a hack and should be replaced with a proper way to prevent this from counting towards total upgrades
			Enum.UPGRADE_METHOD.ABSOLUTE if upgrade.method == "Additiv" else Enum.UPGRADE_METHOD.MULTIPLIER,
			upgrade.value,
			info.text,
			info.display_factor
		))


func _load_json_file(path: String):
	if not FileAccess.file_exists(path):
		printerr("Cannot read file " + path)
		return
	var data = FileAccess.open(path, FileAccess.READ)
	var parsed = JSON.parse_string(data.get_as_text())
	return parsed
