@tool
class_name MusicTransition extends Resource

enum TRANSITIONS {
	CROSSFADE,
	FADE_AND_START,
	INSTANT
	}



@export var type: MusicTransition.TRANSITIONS:
	set(value):
		type = value
		notify_property_list_changed()
	get:
		return type
var transition_parameters:Dictionary = {}

func _get_property_list():
	var properties = []
	match type:
		MusicTransition.TRANSITIONS.CROSSFADE:
			properties.append({
				"name": "duration",
				"type": TYPE_FLOAT,
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "0,10,or_greater,suffix:s"
			})
			transition_parameters = {"duration": 0}
		MusicTransition.TRANSITIONS.FADE_AND_START:
			properties.append({
				"name": "duration",
				"type": TYPE_FLOAT,
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "0,10,or_greater,suffix:s"
			})
			properties.append({
				"name": "next_track_offset",
				"type": TYPE_FLOAT,
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "0,10,or_greater,suffix:s"
			})
			transition_parameters = {"duration": 0, "next_track_offset": 0}
		MusicTransition.TRANSITIONS.INSTANT:
			pass
		
	return properties


func _set(property: StringName, value) -> bool:
	match property:
		"duration":
			transition_parameters.set(property, value)
			return true
		"next_track_offset":
			transition_parameters.set(property, value)
			return true
		_:
			return false

func _get(property: StringName):
	if (transition_parameters.has(property)):
		return transition_parameters[property]

	
static func crossfade(duration: float = 1.0) -> MusicTransition:
	var transition = MusicTransition.new()
	transition.type = MusicTransition.TRANSITIONS.CROSSFADE
	transition.transition_parameters["duration"] = duration
	return transition


static func instant() -> MusicTransition:
	var transition = MusicTransition.new()
	transition.type = MusicTransition.TRANSITIONS.INSTANT
	return transition


static func fade_and_start(duration: float = 1.0, next_track_offset: float = 1.0) -> MusicTransition:
	var transition = MusicTransition.new()
	transition.type = MusicTransition.TRANSITIONS.FADE_AND_START
	transition.transition_parameters["duration"] = duration
	transition.transition_parameters["next_track_offset"] = next_track_offset
	
	return transition
