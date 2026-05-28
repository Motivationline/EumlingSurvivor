@tool
class_name AutoSizeLabel extends Label

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
		"text", "size":
			resize_font()
	return false

func resize_font() -> void:
	_resize_font.call_deferred()

func _resize_font() -> void:
	var font: Font = get_theme_font("font")
	var font_size: int = AutoSizer.calc_font_size(font, text, size.x, min_font_size, max_font_size)
	add_theme_font_size_override("font_size", font_size)
