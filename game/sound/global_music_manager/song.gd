@tool
class_name Song extends AudioStreamInteractive
##Object that contains music files belonging to one track.


## If [param true], will switch to [param next_track] with a [param transition] that can be configured in the inspector after the song ends.
@export var oneshot: bool = false:
	set(value):
		oneshot = value
		notify_property_list_changed()
	get():
		return oneshot
		

var length: float:
	get():
		var _length: float = 0
		for i in range(self.clip_count):
			_length+=get_clip_stream(i).get_length()
		length = _length
		return length

var next_track: SongList.TRACK
var transition: MusicTransition
func _get_property_list():
	var properties = []
	if oneshot:
		properties.append({
		"name": "transition",
		"type": TYPE_OBJECT,
		"hint": PROPERTY_HINT_RESOURCE_TYPE,
		"hint_string": "MusicTransition"
		})
		properties.append({
		"name": "track",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
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
func _get(property: StringName):
	match property:
		"track":
			return next_track
		"transition":
			return transition
