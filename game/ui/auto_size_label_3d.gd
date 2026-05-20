@tool
class_name AutoSizeLabel3D extends Label3D

#region Private Fields

@export 
var maxFontSize = 56

#endregion

#region Public Label3D Methods

func _set( property: StringName, value: Variant ) -> bool:
	# listen for text or width changes
	match property:
		"text":
			_update_font_size( value )
		"width":
			_update_font_size( text )

	return false

#endregion

#region Private Methods

func _update_font_size( textVal: String ) -> void:
	var line = TextLine.new()
	line.direction = text_direction
	line.flags = justification_flags
	line.alignment = horizontal_alignment

	for i in 20:
		line.clear()
		var created = line.add_string( textVal, font, font_size )
		if created:
			var text_size = line.get_line_width()
			if text_size > floor( width ):
				font_size -= 1
			elif font_size < maxFontSize:
				font_size += 1
			else:
				break
		else:
			push_warning( 'Could not create a string' )
			break
	
#endregion
