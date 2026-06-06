@tool
class_name Song extends AudioStreamInteractive

@export var oneshot :bool = false:
	set(value):
		oneshot = value
		notify_property_list_changed()
	get:
		return oneshot


var next_track:SongList.TRACK
var transition: MusicTransition
func _get_property_list():

	var properties = []
	if oneshot:

		properties.append({
		"name": "transition",
		"type": TYPE_OBJECT,
		"hint":PROPERTY_HINT_RESOURCE_TYPE,
		"hint_string": "MusicTransition"
		})
		properties.append({
		"name": "track",
		"type": TYPE_INT,
		"hint":PROPERTY_HINT_ENUM,
		"hint_string": ",".join(SongList.TRACK.keys())
		})

	
	return properties
	

func _set(property, value):
	match property:
		"atrack":
			next_track = value
			return true
		"transition":
			transition = value
			return true
		_:
			return false
func _get(property:StringName):
	match property:
		"track":
			return next_track
		"transition":
			return transition
