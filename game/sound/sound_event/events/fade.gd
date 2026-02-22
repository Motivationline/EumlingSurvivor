@tool
class_name Fade extends SoundEvent


enum FADE_TYPE {OUT, IN}
@export var fade_type:FADE_TYPE
@export var buses:Array[GlobalAudioManager.BUS_ID]

@export var to_initial_volume:bool = false:
	set(value):
		to_initial_volume = value
		notify_property_list_changed()
@export var amount_db:float = 100
@export var fade_duration:float = 2.0


@export_category("Delay")
@export var enabled = false:
	set(value):
		enabled = value
		notify_property_list_changed()

func _validate_property(property: Dictionary):
	if to_initial_volume and property.name == "amount_db":
		property.usage = PROPERTY_USAGE_NONE




var delay_duration ##In seconds
func _get_property_list():
	var properties = []

	if enabled:
		properties.append({
			"name": "duration",
			"type": TYPE_FLOAT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0.01,10, 0.01"
		})
	return properties
func _get(property):
	if property == "duration":
		return delay_duration
func _set(property, val):
	if property == "duration":
		delay_duration = val



func start() -> void:
	if enabled:
		var timer = get_tree().create_timer(delay_duration)
		await timer.timeout
		fade()
	else:
		fade()

func fade():
	var out:bool
	
	match fade_type:
		FADE_TYPE.OUT:
			out = true
		FADE_TYPE.IN:
			out = false
	
	var tween:Tween = GlobalAudioManager.fade_bus_volume(buses, out, fade_duration, amount_db)

	await tween.finished
	if out:
		GlobalAudioManager.stop_music()

	
