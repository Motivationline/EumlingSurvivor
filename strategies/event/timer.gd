extends EventStrategy
## Triggers another Event after the timer ran out
class_name TimerEventStrategy

## how long to wait (in seconds) until the given event gets triggered
@export var wait_time: float = 3

## What event to call once the time is up
@export var event: EventStrategy

func _setup(_parent: Node, _owner: Node):
	super (_parent, _owner)
	event._setup(_parent, _owner)

func execute_event(_data):
	await get_tree().create_timer(wait_time).timeout
	event.event_triggered(_data)
