@tool
class_name AutoSizeLabel3D
extends Label3D
## Automatically adjusts the font size to fit into the label bounds.

@export var label_size := Vector2i(160, 90):
	set(value):
		label_size = value
		apply_label_size()
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

var bounding_box := AutoSizeLabel3DBoundingBox.new()


func _ready() -> void:
	if Engine.is_editor_hint():
		add_child(bounding_box)
	elif is_instance_valid(bounding_box):
		bounding_box.queue_free()

	apply_label_size()


func _set(_property: StringName, _value: Variant) -> bool:
	resize_font()
	return false


func _validate_property(property: Dictionary) -> void:
	match property.name:
		"width", "font_size", "line_spacing":
			property.usage |= PROPERTY_USAGE_READ_ONLY


func apply_label_size() -> void:
	width = label_size.x
	resize_font()


func calc_line_spacing(_font_size: int) -> float:
	return _font_size * line_spacing_ratio


func resize_font() -> void:
	if is_instance_valid(bounding_box):
		bounding_box.update(self)
	_resize_font.call_deferred()


func _resize_font() -> void:
	font_size = AutoSizer.calc_font_size(self, font)
	line_spacing = calc_line_spacing(font_size)
