@tool
class_name SongRequester extends SoundEvent

@export var track:MusicPlayer.TRACK
@export var transition:MusicPlayer.TRANSITIONS
@export var crossfade_duration:float = 0
@export var backround_noise:bool = false



@export_category("Delay")
@export var enabled = false:
	set(value):
		enabled = value
		notify_property_list_changed()
var delay_duration = 0 ##In seconds
func _get_property_list():
	var properties = []

	if enabled:
		properties.append({
			"name": "duration",
			"type": TYPE_FLOAT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0.01,100, 0.01"
		})
	return properties
func _get(_property):
	if _property == "duration":
		return delay_duration
func _set(_property, _val):
	if _property == "duration":
		delay_duration = _val



func start() -> void:
	if enabled:
		var timer = get_tree().create_timer(delay_duration)
		await timer.timeout
	if !GlobalAudioManager.music_playing:
		transition = MusicPlayer.TRANSITIONS.INSTANT
	GlobalAudioManager.request_music(track, transition, crossfade_duration, backround_noise)
