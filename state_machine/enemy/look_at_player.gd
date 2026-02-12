@tool
extends State

## Makes the Entity look at the Player
##
## Ends when the distance from Entity to Player is less than stop_distance
class_name LookAtPlayerState
@export var infinite: bool = false
## pause time after the destination was reached
@export var wait_time: float = 1:
	set(new_value):
		wait_time = max(new_value, 0)

## amount to rotate when directions change
@export_range(0.0,20.0,0.1) var rotation_speed: float = 5

@export_group("Overrides")
## Movement Speed Override
@export_range(0, 100, 0.1) var speed_override: float = 1:
	set(new_value):
		speed_override = max(new_value, 0)
		update_configuration_warnings()
# Whether to apply the speed override
@export var speed_override_active: bool = false

var done: bool = false
var player: CharacterBody3D

func setup(_parent: StateMachinePoweredEntity, _animation_tree: AnimationTree):
	super (_parent, _animation_tree)
	parent = _parent
	player = get_tree().get_nodes_in_group("Player")[0]

func enter():
	done = false
	super()
	if !infinite: wait()

func physics_process(_delta: float) -> State:
	var target_vec = (player.position - parent.position).normalized()
	var target_rotation = atan2(-target_vec.x, -target_vec.z)
	parent.visuals.rotation.y = lerp_angle(parent.visuals.rotation.y, target_rotation ,_delta* rotation_speed)
	if(done) : return return_next()
	return null

func wait():
	await get_tree().create_timer(wait_time).timeout
	done = true
