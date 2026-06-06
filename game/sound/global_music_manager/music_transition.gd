@tool
## Object that holds data to tell the music manager how to transition from one music track to the next
class_name MusicTransition extends Resource

enum TRANSITIONS {
	CROSSFADE,
	FADE_AND_START,
	INSTANT
	}


## Definies the type of transition. [br]
## [param TRANSITIONS.CROSSFADE] fades between two tracks. [br]
## [param TRANSITIONS.FADE_AND_START] fades the previous track and starts the next one at full volume. [br]
## [param TRANSITIONS.INSTANT] cuts to the next track instantly.
@export var type: MusicTransition.TRANSITIONS:
	set(value):
		type = value
		notify_property_list_changed()
	get:
		return type

## Holds transition data depending on the transition [param type]
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

## Creates a transition that fades between two tracks for [param duration] in seconds.
static func crossfade(duration: float = 1.0) -> MusicTransition:
	var transition = MusicTransition.new()
	transition.type = MusicTransition.TRANSITIONS.CROSSFADE
	transition.transition_parameters["duration"] = duration
	return transition

## Creates a transition that instantly cuts to the next track.
static func instant() -> MusicTransition:
	var transition = MusicTransition.new()
	transition.type = MusicTransition.TRANSITIONS.INSTANT
	return transition

## Creates a transition that fades out the previous track for [param duration] in seconds and plays the next one at full volume after [param next_track_offset] in seconds.
static func fade_and_start(duration: float = 1.0, next_track_offset: float = 1.0) -> MusicTransition:
	var transition = MusicTransition.new()
	transition.type = MusicTransition.TRANSITIONS.FADE_AND_START
	transition.transition_parameters["duration"] = duration
	transition.transition_parameters["next_track_offset"] = next_track_offset
	
	return transition
