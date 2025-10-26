extends EventStrategy
## Removes the node when event is called
class_name ActivateEventStrategy

## Add Activation Node pool inside this Array
@export var activate: Array[Node]:
	set(new_value):
		activate = new_value

## trigger the action after a given delay
@export var is_delayed: bool = false
## after delay time has passed, the action is triggered
@export var delay: float = 0

func event_triggered(_data):
	if is_delayed:
		await get_tree().create_timer(delay).timeout
	
	for n in activate:
		#n.show()
		n.is_active = true
		set_process(true)
