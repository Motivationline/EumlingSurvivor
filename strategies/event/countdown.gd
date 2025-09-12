extends EventStrategy
## Counts down every time this event is called before triggering the attached event when countdown reaches 0
class_name CountdownEventStrategy

## How often this event needs to be triggered before the defined event is called.[br]  
## Or in other words: every n-th time this event is called, call the other event.[br]
## 1 -> every time, 2 -> every other time, etc.
@export_range(1, 100) var count: int = 1
var current_count: int

## What event to call once the count is up
@export var event: EventStrategy

## Whether the countdown should only happen once or over and over
@export var once: bool = false
var happened: bool = false

func _setup(_parent: Node):
	super (_parent)
	event._setup(_parent)
	current_count = count

func event_triggered(_data):
	if (once && happened): return
	current_count -= 1
	if (current_count == 0):
			current_count = count
			event.event_triggered(_data)
			happened = true
