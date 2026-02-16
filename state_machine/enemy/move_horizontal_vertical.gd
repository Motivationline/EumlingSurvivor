@tool
extends State
## Uses the levels NavMesh to move the Enemy to a random point inside the level
## 
## Ends when the point is reached.
class_name MoveHorizontalVerticalState

## How long to wait [b]after[/b] reaching the target location before proceeding to the next state 
@export var wait_time: float = 1:
	set(new_value):
		wait_time = max(new_value, 0)

## true = vertical, false = horizontal
@export var direction: bool
## at what distance the entity stops infront of level Geometry
@export var stop_distance: float = 1
## value to control how much the entity "straves"
@export_range(0,360,1) var rotation_offset: float
## raycast to handle pathing
@export var path_ray: RayCast3D

@export_group("Overrides")
## Movement Speed Override
@export_range(0, 100, 0.1) var speed_override: float = 1:
	set(new_value):
		speed_override = max(new_value, 0)
		update_configuration_warnings()
# Whether to apply the speed override
@export var speed_override_active: bool = false

var nav_agent: NavigationAgent3D
var done: bool = false

var move_direction: Vector3

var ray_length = 30

var pos1: Vector3
var pos2: Vector3

func setup(_parent: Enemy, _animation_tree: AnimationTree):
	super (_parent, _animation_tree)

func enter():
	super()
	
	#TODO: create 2 Raycast, shoot front and back, save collision points, move between them
	
	path_ray.global_position = parent.position
	
	move_direction = get_new_direction()

func physics_process(_delta: float) -> State:
	if (done): return return_next()
	
	var speed = speed_override if (speed_override_active) else parent.speed
	parent.velocity = move_direction * speed

	parent.move_and_slide()
	
	# checks if the entity is in stop distance to the target position
	if parent.global_position.distance_to(pos1) < stop_distance || parent.global_position.distance_to(pos2) < stop_distance:
		done = true
		parent.velocity = Vector3.ZERO
	
	return null

func get_new_direction() -> Vector3:
	
	# vertical direction
	if direction:
		parent.rotation.y = 0 + rotation_offset

	# horizontal direction
	else:
		parent.rotation.y = 90 + rotation_offset
	
	#adjust for rotation offset to create "strafe like" behavior
	path_ray.rotation.y -= rotation_offset
	
	#check forwards:
	path_ray.target_position = parent.global_basis.z * ray_length
	
	if path_ray.is_colliding():
		pos1 = path_ray.get_collision_point()
		pos1.y = parent.position.y #make the entity walk on a straight plane
	else:
		pos1 = parent.position
	
	#check backwards:
	path_ray.target_position = -parent.global_basis.z * ray_length
	
	if path_ray.is_colliding():
		pos2 = path_ray.get_collision_point()
		pos2.y = parent.position.y #make the entity walk on a straight plane
	else:
		pos2 = parent.position
	
	#pick direction based on random weights
	var mix: float = randf_range(0,1)
	var vec1: Vector3 = (pos1 - parent.position) * mix
	var vec2: Vector3 = (pos2 - parent.position) * 1/mix
	var result: Vector3 = vec1 + vec2
	var dir = result.normalized()
	
	print("pos1: ", pos1)
	print("pos2: ", pos2)
	print("dir: ", dir)
	return dir

func target_reached():
	await get_tree().create_timer(wait_time).timeout
	done = true

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := super ()
	if (speed_override == 0 && speed_override_active): warnings.insert(0, "Using a speed of 0 means this node will never reach its target.")
	#if (min_distance > max_distance): warnings.insert(0, "Min Distance cannot be larger than Max Distance")
	return warnings
