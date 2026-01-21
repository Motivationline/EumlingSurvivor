@tool
extends State

## Moves the Entity towards the Player 
##
## Ends when the distance from Entity to Player is less than min_distance
class_name FollowPlayerAsFlockState

enum GROUP {ENEMY, MINIEUMLING}

## pause time after the destination was reached
@export var wait_time: float = 1
## amount to rotate when directions change
@export_range(0.0,50.0,0.1) var rotation_speed: float = 5

@export_group("Flock")
## minimum distance to player
@export var min_distance: float
## maximum distance to player
@export var max_distance: float
## flock group
@export var group: GROUP
## the radius in which group members get detected
@export var awareness_radius: float = 1
## how far each member seperates from each other
@export var separation_factor: float = 0.5
## strength of the alignment of each member
@export var alignment_factor: float = 0.5
## how much each member steers towards the average psotion of local members
@export var cohesion_factor: float = 0.5
## FOV (in deg) of the Entities in which they perceive other members
@export_range(0.0,180.0,1) var fov: float = 70
## threshold at what point the entity stops if the neighbor is at standstill
@export var neighbor_stop_threshold: float = 0.3

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

#var nav_agent: NavigationAgent3D
var done: bool = false
var player: CharacterBody3D
var flock_group: String
var is_standstill: bool
var is_leader: bool

# debug
var leader_material := StandardMaterial3D.new()
var normal_material := StandardMaterial3D.new()

# TODO: fix y pos

func setup(_parent: CharacterBase, _animation_tree: AnimationTree):
	super (_parent, _animation_tree)
	parent = _parent
	#nav_agent = NavigationAgent3D.new()
	#parent.add_child(nav_agent)
	# anti-schwebe-zeugs - ist bisschen unklar, warum muss ich das auf 2x cell height setzen damit es richtig funktioniert? :shrug:
	#nav_agent.path_height_offset = ProjectSettings.get_setting("navigation/3d/default_cell_height", 0.25) * 2
	#nav_agent.target_reached.connect(target_reached)
	#nav_agent.target_desired_distance = 0.1
	#nav_agent.path_desired_distance = 0.1
	#nav_agent.debug_enabled = debug_show_path
	player = get_tree().get_nodes_in_group("Player")[0]
	match group:
		GROUP.ENEMY:
			flock_group = "Enemy"
		GROUP.MINIEUMLING:
			flock_group = "MiniEumling"
	
	leader_material.albedo_color = Color.RED
	normal_material.albedo_color = Color.WHITE
	
	define_leader()

func enter():
	super()
	update_target_location()

func physics_process(_delta: float) -> State:
	if (done): return return_next()
	
	update_target_location()
	
	# get the closest nod to the player
	var members: Array[Node] = get_tree().get_nodes_in_group(flock_group)
	var closest = get_closest_node(player as Node3D, members)
	#print(closest)
	
	# if i am the closest, i am the leader
	is_leader = (parent == closest)
	
	# set debug material
	if parent.visualizer:
		if is_leader:
			#parent.visualizer.mesh.surface_set_material(0, leader_material)
			parent.visualizer.set_scale(Vector3.ONE * 0.5)
		else:
			parent.visualizer.set_scale(Vector3.ONE * 0.25)
			#parent.visualizer.mesh.surface_set_material(0, normal_material)

	
	if parent.global_position.distance_to(player.global_position) > max_distance:
		#is_standstill = false
		if is_leader:
			#define_leader()
			#members = get_tree().get_nodes_in_group(flock_group)
			for member in members:
				var sate = member.state_machine.current_state
				if sate is FollowPlayerAsFlockState:
					sate.is_standstill = false
			
		#parent.look_at(nav_agent.get_next_path_position())
		#var destination = nav_agent.get_next_path_position()
		var local_destination =  get_tree().get_first_node_in_group("Player").global_position - parent.global_position 
		var direction = local_destination.normalized()
		var speed = speed_override if (speed_override_active) else parent.speed
		parent.velocity = _flock(direction) * speed
		#parent.velocity = direction * speed
		parent.rotation.y = lerp_angle(parent.rotation.y,atan2(-parent.velocity.x,-parent.velocity.z),_delta* rotation_speed)
		#parent.visuals.rotation.y = lerp_angle(parent.visuals.rotation.y,atan2(-parent.velocity.x,-parent.velocity.z),_delta* rotation_speed)
		parent.move_and_slide()
	else:
		is_standstill = true
	
	#check if the player is closer than stopping distance
	if (player.position - parent.position).length() <= (min_distance):
		target_reached()
	return null

func update_target_location():
	#var target_position = player.position - ((player.position - parent.position).normalized() * min_distance)
	#nav_agent.target_position = target_position
	done = false
	#nav_agent.debug_enabled = debug_show_path

func target_reached():
	#nav_agent.debug_enabled = false
	await get_tree().create_timer(wait_time).timeout
	if done: return
	done = true

# TODO: Flock only moving entities

func _flock(_direction: Vector3) -> Vector3:
	#separation
	var members: Array[Node] = get_tree().get_nodes_in_group(flock_group)
	# remove self from the array
	members.erase(parent)
	
	var members_in_range: Array[Node] = members.filter(func(member):
		return parent.global_position.distance_to(member.global_position) < awareness_radius
	)
	
	if members_in_range.is_empty():
		return _direction.normalized()
	
	#Vision Cone, rm member that is outside of that cone
	for member in members_in_range:
		#var dist = member.global_position - parent.global_position
		#var angle_rad = acos(parent.transform.basis.z.dot(dist))
		var to_member = (member.global_position - parent.global_position)
		var to_member_dir = to_member.normalized()

		var forward = -parent.transform.basis.z.normalized()
		var dot = clamp(forward.dot(to_member_dir), -1.0, 1.0)
		var angle = rad_to_deg(acos(dot))
		
		if angle > fov:
			members_in_range.erase(member)
	
	for member in members_in_range:
		
		var ratio: float = 1.0 - (member.global_position - parent.global_position).length() / separation_factor
		ratio = clamp(ratio, 0.0, 1.0)
		#print(ratio)
		if member.state_machine.current_state is FollowPlayerAsFlockState && member.state_machine.current_state.is_standstill && ratio > 0.3:
			#print("member is satisfied")
			is_standstill = true
			return Vector3.ZERO
		
		_direction -= ratio * (member.global_position - parent.global_position)
	
	_direction = _direction.normalized()
	
	#alignment
	var member_average_dir: Vector3 = Vector3.ZERO
	if len(members_in_range) > 0:
		for member in members_in_range:
			var member_dir = member.velocity.normalized()
			member_average_dir += member_dir
		
		member_average_dir /= len(members_in_range)
		member_average_dir = member_average_dir.normalized()
		
		_direction = lerp(_direction, member_average_dir, alignment_factor)
	
	#cohesion
	var member_average_pos: Vector3 = Vector3.ZERO
	if len(members_in_range) > 0:
		for member in members_in_range:
			var member_pos = member.global_position
			member_average_pos += member_pos
			member_average_pos /= len(members_in_range)
	var dir_to_pos: Vector3 = (member_average_pos - parent.global_position).normalized()
	
	_direction = lerp(_direction, dir_to_pos, cohesion_factor)
	#if not _direction.is_finite():
		#_direction = Vector3.ZERO
	_direction *= Vector3(1,0,1)
	return _direction.normalized()

func define_leader():
	var members = get_tree().get_nodes_in_group(flock_group)
	if members.is_empty(): return

	var closest = get_closest_node(player, members)

	for member in members:
		var state = member.state_machine.current_state
		if state is FollowPlayerAsFlockState:
			state.is_leader = (member == closest)


# TODO: Ich replace das mit der methode aus der Utils Klasse sobald das Gemerged ist
func get_closest_node(_origin: Node3D, _n_targets: Array[Node]):
	var _targets:  Array[Node3D] = []
	for n in _n_targets:
		_targets.push_back(n as Node3D)
		
	if len(_targets) > 0:
		var closest: Node = null
		var closest_dist = INF
		for n: Node in _targets:
			var dist = _origin.global_position.distance_squared_to(n.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest = n
		return closest
