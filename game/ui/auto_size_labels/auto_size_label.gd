@tool
class_name AutoSizeLabel
extends Label
## Automatically adjusts the font size to fit into the label bounds.
## Changing it's size via the bounding box won't work with this label.

@export var label_size := Vector2i(160, 90):
	set(value):
		label_size = value
		size = value
		custom_minimum_size = value
		custom_maximum_size = value
		resize_font()
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


func _ready() -> void:
	# Make sure all values are set correctly when creating a new label.
	label_size = label_size


func _set(_property: StringName, _value: Variant) -> bool:
	resize_font()
	return false


func _validate_property(property: Dictionary) -> void:
	match property.name:
		"size", "custom_minimum_size", "custom_maximum_size":
			property.usage |= PROPERTY_USAGE_READ_ONLY


func calc_line_spacing(font_size: int) -> float:
	return font_size * line_spacing_ratio


func resize_font() -> void:
	_resize_font.call_deferred()


func _resize_font() -> void:
	var font: Font = get_theme_font("font")
	var font_size: int = AutoSizer.calc_font_size(self, font, label_size)
	add_theme_font_size_override("font_size", font_size)
	add_theme_constant_override("line_spacing", int(calc_line_spacing(font_size)))
