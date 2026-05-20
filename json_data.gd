extends Node

const UPGRADE_VALUES = "res://game/upgrade/upgrade_values.json"

var player_upgrade_levels: Dictionary = {}

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


func _load_json_file(path: String):
	if not FileAccess.file_exists(path):
		printerr("Cannot read file " + path)
		return
	var data = FileAccess.open(path, FileAccess.READ)
	var parsed = JSON.parse_string(data.get_as_text())
	return parsed
