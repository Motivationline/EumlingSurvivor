@tool
class_name AutoSizeLabel
extends Label
## Automatically adjusts the font size to fit into the label bounds.

@export var min_font_size: int = 1:
	set(size):
		min_font_size = mini(size, max_font_size)
		resize_font()
@export var max_font_size: int = 120:
	set(size):
		max_font_size = maxi(size, min_font_size)
		resize_font()
## Line Spacing = Font Size * Line Spacing Ratio
@export_range(-1.0, 1.0, 0.01) var line_spacing_ratio: float = 0.0:
	set(ratio):
		line_spacing_ratio = ratio
		resize_font()


func _set(property: StringName, _value: Variant) -> bool:
	match property:
		"text", "size", "autowrap_mode":
			resize_font()
	return false


func create_paragraph() -> TextParagraph:
	var paragraph := TextParagraph.new()
	paragraph.alignment = horizontal_alignment
	paragraph.break_flags = autowrap_trim_flags | AutoSizer.get_break_flags(autowrap_mode)
	paragraph.direction = text_direction as TextServer.Direction
	paragraph.ellipsis_char = ellipsis_char
	paragraph.justification_flags = justification_flags
	paragraph.line_spacing = get_theme_constant("line_spacing")
	paragraph.max_lines_visible = max_lines_visible
	paragraph.text_overrun_behavior = text_overrun_behavior
	paragraph.width = size.x
	return paragraph


func calc_line_spacing(font_size: int) -> int:
	return int(font_size * line_spacing_ratio)


func resize_font() -> void:
	_resize_font.call_deferred()


func _resize_font() -> void:
	var font: Font = get_theme_font("font")
	var _size := Vector2(size.x, font.get_height(max_font_size))
	var font_size: int = AutoSizer.calc_font_size(self, font, _size)
	add_theme_font_size_override("font_size", font_size)
	add_theme_constant_override("line_spacing", calc_line_spacing(font_size))
