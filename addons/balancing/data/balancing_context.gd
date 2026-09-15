@tool
class_name BalancingContext
extends RefCounted

var entry_index: int = -1
var scene: String = ""
var difficulty: int = -1
var target: String = ""
var attribute: String = ""


func set_entry(index: int, scene_name: String = "", difficulty_level: int = -1) -> void:
	entry_index = index
	scene = scene_name
	difficulty = difficulty_level
	target = ""
	attribute = ""


func set_scene(scene_name: String) -> void:
	entry_index = -1
	scene = scene_name
	difficulty = -1
	target = ""
	attribute = ""


func set_target(target_name: String) -> void:
	target = target_name
	attribute = ""


func set_attribute(attribute_name: String) -> void:
	attribute = attribute_name
