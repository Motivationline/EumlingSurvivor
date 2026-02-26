@tool
extends State

## Makes the entity accelerate in the direction its facing while stying on the navmesh
##
## Ends when the Entity reached the max distance, max time, or hit a wall (configurable)
class_name AccelerateOnNavMeshState

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

@export_group("Debug")
## Show the paths during gameplay
@export var debug_show_path: bool = false

var nav_agent: NavigationAgent3D
var done: bool = false
var last_valid_pos: Vector3

func setup(_parent: Enemy, _animation_tree: AnimationTree):
	super (_parent, _animation_tree)
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	
	nav_agent = NavigationAgent3D.new()
	parent.add_child(nav_agent)
	# anti-schwebe-zeugs - ist bisschen unklar, warum muss ich das auf 2x cell height setzen damit es richtig funktioniert? :shrug:
	nav_agent.path_height_offset = ProjectSettings.get_setting("navigation/3d/default_cell_height", 0.25) * 2
	#nav_agent.navigation_finished.connect(target_reached)
	nav_agent.debug_enabled = debug_show_path
	nav_agent.target_desired_distance = 0.001

func enter():
	super ()
	start_position = parent.global_position
	timer.start(max_time)
	start_speed = parent.speed
	last_valid_pos = parent.global_position
	done = false
	#print("start speed: ", start_speed)

func exit() -> void:
	super ()
	timer.stop()

func physics_process(_delta: float) -> State:
	if (end_condition_reached()): 
		return return_next()
		
	#if (nav_agent.is_navigation_finished()): return null
	
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
		done = true
	
	nav_agent.target_position = parent.global_position
	var adjusted_final_pos = nav_agent.get_final_position()
	adjusted_final_pos.y = parent.global_position.y
	if  adjusted_final_pos.distance_to(parent.global_position) >= 0.001 :
		#we left the navmesh
		#print("parent pos: ", parent.global_position)
		#print("target pos: ", adjusted_final_pos)
		parent.global_position = last_valid_pos
		done = true
		#print("we left the navmesh")
	else:
		last_valid_pos = parent.global_position
		#print("we are on the navmesh")
	
	return null

func end_condition_reached() -> bool:
	if (timer.is_stopped()): return true
	if (start_position.distance_to(parent.global_position) >= max_distance): return true
	if (done): return true
	return false
