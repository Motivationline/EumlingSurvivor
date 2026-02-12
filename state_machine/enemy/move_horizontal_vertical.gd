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

var ray: RayCast3D = RayCast3D.new()
var ray_length = 1
var move_direction: Vector3

func setup(_parent: Enemy, _animation_tree: AnimationTree):
	super (_parent, _animation_tree)
	
	#TODO: why only works once

func enter():
	super()
	#TODO: look for a better way to prevent duplicates or the ray existing even after the state has been "force swapped"
	var childs = parent.get_children()
	
	var ray_duplicate = childs.filter(func(node): return node.name == "raymond")
	if ray_duplicate != null:
		print("raymond does not exist yet")
		ray.name = "raymond"
		parent.add_child(ray)
	else:
		print("found a duplicate")
		ray = ray_duplicate[0]
		
	#for node in childs:
		#if node.name == "raymond":
			#print("found a duplicate")
			#ray = node
		#else:
			#print("raymond does not exist yet")
			#ray.name = "raymond"
			#parent.add_child(ray)
	
	ray.global_position = parent.position
	
	move_direction = get_new_direction()

func physics_process(_delta: float) -> State:
	if (done): return return_next()
	
	var speed = speed_override if (speed_override_active) else parent.speed
	parent.velocity = move_direction * speed

	parent.move_and_slide()
	
	#print("Ray pos: ", ray.global_position)
	#print("enemy pos: ", parent.global_position)
	
	if ray.is_colliding():
		print("coliding with wall")
		#get the colliders group and check if its the level
		if ray.get_collider().is_in_group("Level"):
			print("hit level")
			done = true
	return null

func get_new_direction() -> Vector3:
	# vertical direction
	if direction:
		var dir: Vector3 = Vector3(0,0,randf_range(-1,1)).normalized()
		
		ray.target_position = dir * ray_length
		
		if ray.is_colliding() && ray.get_collider().is_in_group("Level"):
			#this direction is INVALID 😮😮😮
			#try flipped direction
			print("this dir is invalid: ", dir)
			dir = dir * -1
			ray.target_position = dir * ray_length
		else:
			print("this dir is valid: ", dir)
			return dir
		if ray.is_colliding()  && ray.get_collider().is_in_group("Level"):
			#now we have a problem, we stuck 😬😬😬
			#enter next state
			done = true
			print("we are stuck")
			return Vector3.ZERO
		else:
			return dir
			print("this dir is valid: ", dir)
	# horizontal direction
	else:
		var dir: Vector3 = Vector3(randf_range(-1,1),0,0).normalized()

		ray.target_position = dir * ray_length
		
		if ray.is_colliding()  && ray.get_collider().is_in_group("Level"):
			#this direction is INVALID 😮😮😮
			#try flipped direction
			dir = dir * -1
			ray.target_position = dir * ray_length
		else:
			return dir
		if ray.is_colliding()  && ray.get_collider().is_in_group("Level"):
			#now we have a problem, we stuck 😬😬😬
			#enter next state
			done = true
			return Vector3.ZERO
		else:
			return dir
	#done = false

func target_reached():
	await get_tree().create_timer(wait_time).timeout
	done = true

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := super ()
	if (speed_override == 0 && speed_override_active): warnings.insert(0, "Using a speed of 0 means this node will never reach its target.")
	#if (min_distance > max_distance): warnings.insert(0, "Min Distance cannot be larger than Max Distance")
	return warnings
