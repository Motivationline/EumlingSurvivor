extends Node

var _unlocked_mini_eumlings: Array[Enum.EUMLING_TYPE] = []
var _active_mini_eumlings: Array[Enum.EUMLING_TYPE] = []
	
signal active_eumlings_changed(active_mini_eumlings: Array[Enum.EUMLING_TYPE])

func unlocked_eumling(type: Enum.EUMLING_TYPE):
	_active_mini_eumlings.push_back(type)
	_unlocked_mini_eumlings.push_back(type)
	active_eumlings_changed.emit(_active_mini_eumlings)

func end_game():
	_active_mini_eumlings.clear()


var is_on_mobile: bool = false

func _ready() -> void:
	is_on_mobile = OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios")
