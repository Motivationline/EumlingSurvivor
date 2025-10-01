@tool
extends Strategy

class_name TimeoutEventManager

@export var timer: Timer:
	set(new_value):
		timer = new_value
		update_configuration_warnings()
@export var on_timeout: Array[EventStrategy]

func _setup(_parent: Node, _owner: Node) -> void:
	super (_parent, _owner)
	Strategy._setup_array(on_timeout, _parent, _owner)

	timer.timeout.connect(timeout)

func timeout():
	for event in on_timeout:
		event.event_triggered(null)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if (!timer): warnings.append("Needs a timer attached")
	return warnings
