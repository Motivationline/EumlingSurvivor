extends ProjectileMovementStrategy
## Controls the projectiles direction
class_name NewTargetProjectileMovementStrategy

## the range in that the projectile registers Enemies
@export var homing_range = 10
## amount to rotate when directions change
@export_range(0.0,20.0,0.1) var rotation_speed: float = 15
## inversed inertia
@export_range(0.0,50,0.1) var velocity_change_rate: float = 30

var target: Node3D = Node3D.new()
var isPlayer: bool = true

func _setup(_parent: Node, _owner: Node):
	super (_parent, _owner)
	if get_tree().get_nodes_in_group("Enemy").has(_owner):
		target = get_tree().get_nodes_in_group("Player")[0]
		isPlayer = false
	else:
		isPlayer = true
		var enemies = get_tree().get_nodes_in_group("Enemy")
		target = get_closest_Node_without(parent, enemies, get_closest_Node(parent, enemies))
		print("new target")

func apply_movement(_delta: float, _current_lifetime: float, _total_lifetime: float):
	# checks if the target is in the homing range
	if target.global_position.distance_to(parent.global_position) <= homing_range:
		var speed_mag = parent.velocity.length()
		var new_dir = lerp(parent.velocity.normalized(), (target.position - parent.position).normalized(), _delta * velocity_change_rate)
		#parent.velocity = lerp(parent.velocity, (target.position - parent.position).normalized() * speed, _delta * rotation_speed)
		parent.velocity = new_dir * speed_mag
		parent.rotation.y = lerp_angle(parent.rotation.y,atan2(-parent.velocity.x,-parent.velocity.z),_delta* rotation_speed)

# returns the closest Node from the given Array
func get_closest_Node(_target, _nodes: Array[Node]):
	var closest: Node3D = null
	var closest_dist = INF
	var enemies: Array[Node] = _nodes
	for n: Node3D in enemies:
		var dist = parent.global_position.distance_to(n.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = n
	return closest

func get_closest_Node_without(_target, _nodes: Array[Node], _exception):
	var closest: Node3D = null
	var closest_dist = INF
	var enemies: Array[Node] = _nodes
	for n: Node3D in enemies:
		if n != _exception:
			var dist = parent.global_position.distance_to(n.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest = n
	return closest
# returns true if a node from the given Array is in Range of _target
#func node_in_range(_range: float, _target, _nodes: Array[Node]):
	#var enemies = _nodes
	#for n: Node3D in enemies:
		#var dist = _target.global_position.distance_to(n.global_position)
		#if dist < _range:
			#return true
	#return false
