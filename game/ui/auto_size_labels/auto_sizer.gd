class_name AutoSizer
## Helper functions for the auto size labels.


## Calculates the largest font size that fits within the label bounds.
static func calc_font_size(label: Variant, font: Font) -> int:
	if label is not AutoSizeLabel and label is not AutoSizeLabel3D:
		return -1

	if not font:
		push_warning("No font assigned to: " + label.name + ". A fallback font will be used.")
		font = SystemFont.new()

	var width: float = -1 if label.autowrap_mode == TextServer.AUTOWRAP_OFF else label.label_size.x
	var break_flags: int = get_break_flags(label.autowrap_mode)
	var text_direction: TextServer.Direction = label.text_direction as TextServer.Direction

	var comparable := func(middle: float) -> bool:
		var font_size := int(middle)

		var text_size: Vector2 = font.get_multiline_string_size(
				label.text,
				label.horizontal_alignment,
				width,
				font_size,
				-1,
				break_flags,
				label.justification_flags,
				text_direction)

		var line_count := int(text_size.y / font.get_height(font_size))
		var line_spacing: float = label.calc_line_spacing(font_size)
		var total_spacing: float = line_spacing * maxf(0, line_count - 1)

		return text_size.x <= label.label_size.x and text_size.y + total_spacing <= label.label_size.y

	return int(Utils.binary_search(label.min_font_size, label.max_font_size, comparable))


## Calculates the largest font size that fits within the label bounds, taking rich text and BBCode into account.
static func calc_rich_font_size(label: AutoSizeRichTextLabel) -> int:
	var comparable := func(middle: float) -> bool:
		var font_size := int(middle)

		label.set_line_separation(font_size)
		label.bulk_rich_font_size_override(font_size)

		var text_size := Vector2(label.get_content_width(), label.get_content_height())
		return text_size.x <= label.label_size.x and text_size.y <= label.label_size.y

	return int(Utils.binary_search(label.min_font_size, label.max_font_size, comparable))


## Gets the correct BitField[LineBreakFlag] from the labels AutoWrapMode.
static func get_break_flags(autowrap_mode: TextServer.AutowrapMode) -> int:
	match autowrap_mode:
		TextServer.AUTOWRAP_OFF:
			return TextServer.BREAK_MANDATORY
		TextServer.AUTOWRAP_ARBITRARY:
			return TextServer.BREAK_MANDATORY | TextServer.BREAK_GRAPHEME_BOUND
		TextServer.AUTOWRAP_WORD:
			return TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND
		TextServer.AUTOWRAP_WORD_SMART:
			return TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND | TextServer.BREAK_ADAPTIVE
	return TextServer.BREAK_NONE
