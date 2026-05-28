# AutoSizer is just a class to remove the hassle of code duplication. Feel free to remove it, if you only need one type of Label.
class_name AutoSizer

## Calculate the best font size using binary search
static func calc_font_size(font: Font, text: String, width: float, low: int, high: int) -> int:
	var comparable := func(mid: int) -> bool:
		var text_size: Vector2 = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, mid)
		return text_size.x <= width

	return Utils.binary_search_int(low, high, comparable)

## Calculate the best font size using binary search, while taking rich text/bbcode into account
static func calc_rich_font_size(label: AutoSizeRichTextLabel) -> int:
	var comparable := func(mid: int) -> bool:
		label.add_theme_font_size_override("normal_font_size", mid)
		return label.get_content_width() <= label.size.x

	return Utils.binary_search_int(label.min_font_size, label.max_font_size, comparable)
