@tool
extends State

## Makes the entity move forwards in its own previously set direction
##
## Ends when the Entity reached the max distance, max time, or hit a wall (configurable)
class_name AccelerateState

## What is the maximum distance you can move?
@export_range(0, 1000) var max_distance: float = 100
## What is the maximum time you can move?
@export_range(0, 1000) var max_time: float = 100
## Stop moving when we hit a wall
@export var stop_when_running_into_something: bool = true
## in units/second
@export var acceleration: float = 5
## resets the speed to the start speed when the state ends
@export var reset_speed_at_end: bool = true

@export var max_speed: float = 50

var start_position: Vector3
var start_speed: float
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
	start_speed = parent.speed
	#print("start speed: ", start_speed)

func exit() -> void:
	super ()
	timer.stop()

func physics_process(_delta: float) -> State:
	if (end_condition_reached()): 
		return return_next()
	
	var speed = parent.speed
	if speed < max_speed:
		speed += acceleration * _delta
	parent.speed = speed
	var collision := parent.move_and_collide((-parent.basis.z) * speed * _delta)
	if (collision && stop_when_running_into_something):
		if reset_speed_at_end:
			parent.speed = start_speed
			speed = start_speed
			# this line is needed for the start speed to be applied
			parent.move_and_collide((-parent.basis.z) * speed * _delta)
		return return_next()

	return null

func end_condition_reached() -> bool:
	if (timer.is_stopped()): return true
	if (start_position.distance_to(parent.global_position) >= max_distance): return true
	return false
