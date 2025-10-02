extends ProjectileMovementStrategy
## Controls the projectiles direction
class_name MoveToTargetProjectileMovementStrategy

## amount to rotate when directions change
@export_range(0.0,20.0,0.1) var rotation_speed: float = 15
## inversed inertia
@export_range(0.0,50,0.1) var velocity_change_rate: float = 30

var targets: Array[Node] = []
var isPlayer: bool = true

func _setup(_parent: Node, _owner: Node):
	super (_parent, _owner)
	if get_tree().get_nodes_in_group("Enemy").has(_owner):
		parent._set_targets()
		targets = parent._get_targets()
		isPlayer = false
	else:
		isPlayer = true

func apply_movement(_delta: float, _current_lifetime: float, _total_lifetime: float):
	#checks if the projectile is fired from the player and adjusts the target accordingly
	if isPlayer:
		if len(targets) > 0:
			var target = targets[0]
			if target:
				var speed_mag = parent.velocity.length()
				var new_dir = lerp(parent.velocity.normalized(), (target.position - parent.position).normalized(), _delta * velocity_change_rate)
				#parent.velocity = lerp(parent.velocity, (target.position - parent.position).normalized() * speed, _delta * rotation_speed)
				parent.velocity = new_dir * speed_mag
				parent.rotation.y = lerp_angle(parent.rotation.y,atan2(-parent.velocity.x,-parent.velocity.z),_delta* rotation_speed)
		
