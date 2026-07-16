@tool
## Starts a timer when the state starts, returning true once the timer has ended
class_name TimerInterruptCondition extends InterruptCondition

@export var min_time: float = 1
@export var max_time: float = 1

var timer: Timer

func _ready() -> void:
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)

func start():
	super()
	timer.start(randf_range(min_time, max_time))

func evaluate() -> bool:
	return timer.time_left == 0
