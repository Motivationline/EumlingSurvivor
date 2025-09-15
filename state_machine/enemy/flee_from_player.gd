@tool
extends State

## Moves the Entity away from the Player 
##
## Ends when the Entity reached the targeted fleeing distance
class_name FleeFromPlayerState

## pause time after the destination was reached
@export var wait_time: float = 1
## distance to the Player where this State ends
@export var flee_distance: float = 10
## amount to rotate when directions change
@export_range(0.0,20.0,0.1) var rotation_speed: float = 5
@export_category("Time Based Fleeing")
## toggle time based flee behavior
@export var time_based: bool = false
## for how long the Entity flees from the player
@export var target_flee_time: float = 10

@export_group("Overrides")
## Movement Speed Override
@export_range(0, 100, 0.1) var speed_override: float = 1:
	set(new_value):
		speed_override = max(new_value, 0)
		update_configuration_warnings()
# Whether to apply the speed override
@export var speed_override_active: bool = false

@export_category("Debug")
@export var debug_show_path: bool

var nav_agent: NavigationAgent3D
var done: bool = false
var player: CharacterBody3D
# for how long this entity has been fleeing
var time_fleeing: float = 0

func setup(_parent: Enemy, _animation_tree: AnimationTree):
	super (_parent, _animation_tree)
	parent = _parent
	nav_agent = NavigationAgent3D.new()
	parent.add_child(nav_agent)
	# anti-schwebe-zeugs - ist bisschen unklar, warum muss ich das auf 2x cell height setzen damit es richtig funktioniert? :shrug:
	nav_agent.path_height_offset = ProjectSettings.get_setting("navigation/3d/default_cell_height", 0.25) * 2
	nav_agent.target_reached.connect(target_reached)
	nav_agent.target_desired_distance = 0.1
	nav_agent.debug_enabled = debug_show_path
	player = get_tree().get_nodes_in_group("Player")[0]

func enter():
	super()
	update_target_location()
	time_fleeing = 0

func physics_process(_delta: float) -> State:
	if (done): return return_next()
	if (nav_agent.is_navigation_finished()): return null
	
	update_target_location()
	
	#parent.look_at(nav_agent.get_next_path_position())
	var destination = nav_agent.get_next_path_position()
	var local_destination = destination - parent.global_position
	var direction = local_destination.normalized()
	var speed = speed_override if (speed_override_active) else parent.speed
	parent.velocity = direction * speed
	parent.rotation.y = lerp_angle(parent.rotation.y,atan2(-parent.velocity.x,-parent.velocity.z),_delta* rotation_speed)
	
	parent.move_and_slide()
	#check if the player is farther than flee_distance or the target fleeing time has been reached
	if !time_based && (player.position - parent.position).length() >= flee_distance:
		print((player.position - parent.position).length())
		target_reached()
	elif time_fleeing >= target_flee_time:
		target_reached()
	time_fleeing += _delta
	
	return null

func update_target_location():
	var target_position
	if(!time_based):
		target_position = parent.position + ((parent.position - player.position).normalized() * (flee_distance - (parent.position - player.position).length()))
	else :
		target_position = parent.position + ((parent.position - player.position).normalized() * ((target_flee_time - time_fleeing) * parent.speed))
	nav_agent.target_position = target_position
	done = false
	nav_agent.debug_enabled = debug_show_path

func target_reached():
	print("target reached")
	nav_agent.debug_enabled = false
	await get_tree().create_timer(wait_time).timeout
	done = true
