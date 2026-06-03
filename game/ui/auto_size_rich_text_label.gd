@tool
class_name AutoSizeRichTextLabel
extends RichTextLabel
## Automatically adjusts the font size(s) to fit into the label bounds.

@export var min_font_size: int = 1:
	set(size):
		min_font_size = mini(size, max_font_size)
		resize_font()
@export var max_font_size: int = 120:
	set(size):
		max_font_size = maxi(size, min_font_size)
		resize_font()
## Line Spacing = Normal Font Size * Line Spacing Ratio
@export_range(-1.0, 1.0, 0.01) var line_spacing_ratio: float = 0.0:
	set(ratio):
		line_spacing_ratio = ratio
		resize_font()

@export_group("Font Size Ratios")
## Bold Font Size = Normal Font Size * Bold Font Size Ratio
@export_range(0.0, 4.0, 0.01) var bold_font_size_ratio: float = 1.0:
	set(ratio):
		bold_font_size_ratio = ratio
		resize_font()
## Bold Italics Font Size = Normal Font Size * Bold Italics Font Size Ratio
@export_range(0.0, 4.0, 0.01) var bold_italics_font_size_ratio: float = 1.0:
	set(ratio):
		bold_italics_font_size_ratio = ratio
		resize_font()
## Italics Font Size = Normal Font Size * Italics Font Size Ratio
@export_range(0.0, 4.0, 0.01) var italics_font_size_ratio: float = 1.0:
	set(ratio):
		italics_font_size_ratio = ratio
		resize_font()
## Mono Font Size = Normal Font Size * Mono Font Size Ratio
@export_range(0.0, 4.0, 0.01) var mono_font_size_ratio: float = 1.0:
	set(ratio):
		mono_font_size_ratio = ratio
		resize_font()


func _set(property: StringName, _value: Variant) -> bool:
	match property:
		"text", "size", "bbcode_enabled", "autowrap_mode":
			resize_font()
	return false


func bulk_rich_font_size_override(normal_font_size: int) -> void:
	begin_bulk_theme_override()
	add_theme_font_size_override("normal_font_size", normal_font_size)
	add_theme_font_size_override("bold_font_size", int(normal_font_size * bold_font_size_ratio))
	add_theme_font_size_override("bold_italics_font_size", int(normal_font_size * bold_italics_font_size_ratio))
	add_theme_font_size_override("italics_font_size", int(normal_font_size * italics_font_size_ratio))
	add_theme_font_size_override("mono_font_size", int(normal_font_size * mono_font_size_ratio))
	end_bulk_theme_override()


func set_line_separation(font_size: int) -> void:
	add_theme_constant_override("line_separation", int(font_size * line_spacing_ratio))


func resize_font() -> void:
	_resize_font.call_deferred()


func _resize_font() -> void:	
	var font_size: int = AutoSizer.calc_rich_font_size(self)
	bulk_rich_font_size_override(font_size)
	set_line_separation(font_size)
