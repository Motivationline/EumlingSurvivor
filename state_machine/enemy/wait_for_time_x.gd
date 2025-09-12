@tool
extends State
## Let The Entity wait
class_name WaitForTimeX

## Wait Time, default 1 sec
@export var wait_time: float = 1:
	set(new_value):
		wait_time = max(new_value, 0)

## optional random Wait Time overwrite
@export_category("Random Wait Time")

@export var random: bool = false

## default 0
@export var min: float = 0
## default 1
@export var max: float = 1

var done: bool = false

func setup(_parent: Enemy, _animation_tree: AnimationTree):
	super (_parent, _animation_tree)
	done = false

func enter():
	super()
	done = false
	wait()

func physics_process(_delta: float) -> State:
	if(done) : return return_next()
	return null

func wait():
	if random:
		wait_time = randf_range(min, max)
	await get_tree().create_timer(wait_time).timeout
	done = true
	
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := super ()
	return warnings
