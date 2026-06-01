class_name AutoSizer
## Helper functions for the auto size labels.


## Calculates the largest font size that fits within the label bounds.
static func calc_font_size(label: Variant, font: Font, size: Vector2) -> int:
	if label is not AutoSizeLabel and label is not AutoSizeLabel3D:
		return -1
	
	var paragraph: TextParagraph = label.create_paragraph()

	var comparable := func(middle: float) -> bool:
		paragraph.clear()
		paragraph.line_spacing = label.calc_line_spacing(middle)
		paragraph.add_string(label.text, font, int(middle), label.language)

		var text_size: Vector2 = paragraph.get_size()
		return text_size.x <= size.x and text_size.y <= size.y

	return int(Utils.binary_search(label.min_font_size, label.max_font_size, comparable))


## Calculates the largest font size that fits within the label bounds, taking rich text and BBCode into account.
static func calc_rich_font_size(label: AutoSizeRichTextLabel) -> int:
	var comparable := func(middle: float) -> bool:
		label.set_line_separation(int(middle))
		label.bulk_rich_font_size_override(int(middle))
		
		var text_size := Vector2(label.get_content_width(), label.get_content_height())
		return text_size.x <= label.size.x and text_size.y <= label.size.y

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
