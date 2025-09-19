extends ProjectileMovementStrategy
## Controls the projectiles direction matching to its velocities direction
class_name RotateToVelocityProjectileMovementStrategy

## amount to rotate when directions change
@export_range(0.0,20.0,0.1) var rotation_speed: float = 15

func _setup(_parent: Node, _owner: Node):
	super (_parent, _owner)

func apply_movement(_delta: float, _current_lifetime: float, _total_lifetime: float):
	parent.rotation.y = lerp_angle(parent.rotation.y,atan2(-parent.velocity.x,-parent.velocity.z),_delta* rotation_speed)
