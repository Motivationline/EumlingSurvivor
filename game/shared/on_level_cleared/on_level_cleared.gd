class_name OnLevelCleared
extends Node

signal level_cleared

@export var enabled: bool = true


func _ready() -> void:
	var level: Level = get_tree().get_first_node_in_group("Level") as Level
	if not level:
		push_warning("Could not find the level.")
		return
	
	if enabled:
		level.level_cleared.connect(emit_level_cleared)


func emit_level_cleared() -> void:
	level_cleared.emit()
