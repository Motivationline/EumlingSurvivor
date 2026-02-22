@tool
class_name Fade extends SoundEvent


enum FADE_TYPE {OUT, IN}
@export var fade_type:FADE_TYPE
@export var buses:Array[GlobalAudioManager.BUS_ID]

@export var to_initial_volume:bool = false:
	set(value):
		to_initial_volume = value
		notify_property_list_changed()
@export var amount_db:float = 30
@export var fade_duration:float = 2.0

func _validate_property(_property: Dictionary):
	if to_initial_volume and _property.name == "amount_db":
		_property.usage = PROPERTY_USAGE_NONE




func start() -> void:
	fade()

func fade():
	var out:bool
	
	match fade_type:
		FADE_TYPE.OUT:
			out = true
		FADE_TYPE.IN:
			out = false
	
	var tween:Tween = GlobalAudioManager.fade_bus_volume(buses, out, fade_duration, amount_db, to_initial_volume)

	await tween.finished
	finished.emit()
	if out:

		GlobalAudioManager.stop_music()
