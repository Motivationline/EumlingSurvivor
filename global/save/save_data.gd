extends Node

const FILE_PATH = "user://savedata.esave"

var _data: Dictionary = {}

func _ready() -> void:
	_load_data()

func get_data(key: String, default: Variant = null) -> Variant:
	return _data.get(key, default)

func set_data(key: String, data: Variant) -> void:
	_data.set(key, data)
	_save_data()

func _save_data():
	var file := FileAccess.open(FILE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(_data))
	prints("saved data")

func _load_data():
	if not FileAccess.file_exists(FILE_PATH):
		return
	var file := FileAccess.open(FILE_PATH, FileAccess.READ)
	var text_content = file.get_as_text()
	_data = JSON.parse_string(text_content)
