@tool
class_name AutoSizeLabel3D extends Label3D

@export var min_font_size: int = 1:
	set(size):
		min_font_size = size
		resize_font()

@export var max_font_size: int = 120:
	set(size):
		max_font_size = size
		resize_font()

func _set(property: StringName, _value: Variant) -> bool:
	match property:
		"text", "width":
			resize_font()
	return false

func resize_font() -> void:
	_resize_font.call_deferred()

func _resize_font() -> void:
	font_size = AutoSizer.calc_font_size(font, text, width, min_font_size, max_font_size)
