extends Node

var unlocked_mini_eumlings: Array[Enum.EUMLING_TYPE] = []
var active_mini_eumlings: Array[Enum.EUMLING_TYPE] = []
var is_on_mobile: bool = false


func _ready() -> void:
	is_on_mobile = OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios")