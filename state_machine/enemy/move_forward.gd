@tool
extends State

## Makes the entity move forwards in its own previously set direction
##
## Ends when the Entity reached the max distance, max time, or hit a wall (configurable)
class_name MoveForwardState

## What is the maximum distance you can move?
@export_range(0, 1000) var max_distance: float = 100
## What is the maximum time you can move?
@export_range(0, 1000) var max_time: float = 100
## Stop moving when we hit a wall
@export var stop_when_running_into_something: bool = true


@export_group("Overrides")
## Movement Speed Override
@export_range(0, 100, 0.1) var speed_override: float = 1
# Whether to apply the speed override
@export var speed_override_active: bool = false


var start_position: Vector3
var timer: Timer


func setup(_parent: Enemy, _animation_tree: AnimationTree):
	super (_parent, _animation_tree)
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)

func enter():
	super ()
	start_position = parent.global_position
	timer.start(max_time)

func exit() -> void:
	super ()
	timer.stop()

func physics_process(_delta: float) -> State:
	if (end_condition_reached()): 
		return return_next()
	
	var speed = speed_override if (speed_override_active) else parent.speed
	var collision := parent.move_and_collide((-parent.visuals.basis.z) * speed * _delta)
	if (collision && stop_when_running_into_something):
		return return_next()

	return null

func end_condition_reached() -> bool:
	if (timer.is_stopped()): return true
	if (start_position.distance_to(parent.global_position) >= max_distance): return true
	return false
