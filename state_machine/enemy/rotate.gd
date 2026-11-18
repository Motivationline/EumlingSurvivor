@tool

## Rotate by a set amount of degrees
class_name RotateState extends State

## Amount of degrees to turn, counterclockwise. Negative values for clockwise
@export var degrees: float = 0.0

## How long it takes for the rotation to happen. 0 or negative = instantaneous
@export var rotation_time: float = 0.0

var done: bool = false

func enter() -> void:
	done = false
	if rotation_time <= 0:
		parent.visuals.rotation.y += deg_to_rad(degrees)
		done = true
		return
	
	var tween = create_tween()
	tween.tween_property(parent.visuals.rotation, "y", parent.visuals.rotation.y + deg_to_rad(degrees), rotation_time)
	await tween.finished
	done = true

func process(_delta: float) -> State:
	if done:
		return return_next()
	return null