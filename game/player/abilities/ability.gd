@abstract
class_name Ability extends Node

var _type: Enum.EUMLING_TYPE
var amt_eumlings: int = 0

func _ready() -> void:
	Data.active_eumlings_changed.connect(update_level)

func update_level(active_mini_eumlings: Array[Enum.EUMLING_TYPE]):
	amt_eumlings = 0
	amt_eumlings = active_mini_eumlings.count(_type)
	prints("update_level", amt_eumlings)