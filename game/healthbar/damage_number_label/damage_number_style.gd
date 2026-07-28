class_name DamageNumberStyle
extends Resource

@export var scale: float = 1.0
@export var color := Color.WHITE
@export var suffix: String = ""


func _init(_scale: float = 1.0, _color := Color.WHITE, _suffix: String = "") -> void:
	scale = _scale
	color = _color
	suffix = _suffix

func copy() -> DamageNumberStyle:
	return DamageNumberStyle.new(scale, color, suffix)
