extends ProjectileMovementStrategy
## Moves the projectile in a parabolic way
class_name ArtilleryToTargetProjectileMovementStrategy

## amount to rotate when directions change
@export_range(0.0,20.0,0.1) var rotation_speed: float = 15
## how quick the direction of the velocity changes (grater values = faster)
@export_range(0.0,50,0.1) var velocity_change_rate: float = 30

@export var speed_amp: float = 10

@export var arc_factor: float = 2

var isPosLocked: bool = false
var start_pos: Vector3
var target_pos: Vector3
var distance: float
var traveled: float

func _setup(_parent: Node, _owner: Node):
	super (_parent, _owner)
	start_pos = parent.position
	parent.velocity = Vector3.ZERO

func apply_movement(_delta: float, _current_lifetime: float, _total_lifetime: float):
	#checks if the projectile is fired from the player and adjusts the target accordingly
	if len(parent.get_targets()) > 0:
		var target = parent.get_targets()[0]
		if target:
			
			#parabula y = x/z
			#line: player -> targetpos
			
			if not isPosLocked:
				target_pos = target.position
				distance = (target_pos - start_pos).length()
				
				var parab_length = calculate_parabua_length((-arc_factor / distance), arc_factor,0 , distance)
				var travel_time = calculate_travel_time(parab_length, speed_amp)
				# rougth estimate
				var adjusted_target_position = target.position + target.velocity * travel_time
				
				target_pos = adjusted_target_position
				distance = (target_pos - start_pos).length()
				
				isPosLocked = true
			
			var parent_pos = parent.position
			#parent_pos.y = 0
			
			traveled = ((start_pos - Vector3(0,start_pos.y,0))- (parent_pos - Vector3(0,parent_pos.y,0))).length()
			# x is the amount we already traveled in target position
			var x = traveled
			# calculate the y-pos for x (how far we traveled to the target) on the parabula
			# the parabula ranges from start_pos to target_pos
			var y = (-arc_factor / distance) * x * x + arc_factor * x
			# calculate the gradient (steigung) at a certain point
			# use the gradient to calculate the angle the projectile should be at on every point
			var gradient = arc_factor/distance * (- 2*x + distance)
			
			
			# horizontal direction from start to target
			var horizontal_dir = (target_pos - start_pos)
			horizontal_dir.y = 0
			horizontal_dir = horizontal_dir.normalized()

			# slope at current point
			var slope = gradient

			# build direction vector
			var dir = horizontal_dir + Vector3.UP * slope
			dir = dir.normalized()

			parent.velocity = dir * speed_amp
			
			if parent.velocity.length() > 0:
				parent.look_at(parent.global_position + parent.velocity)

func calculate_travel_time(_length:float, _speed: float) -> float:
	var t = _length/_speed
	return t
	

# die Funktionen sind von AI und berechnen die Länge eines Abschnittes einer Parabel
func _F(x: float, a: float, b: float) -> float:
	var u = 2.0 * a * x + b
	return (u * sqrt(1.0 + u * u) + asinh(u)) / (4.0 * a)

func calculate_parabua_length(a: float, b: float, x0: float, x1: float) -> float:
	if abs(a) < 0.000001:
		return sqrt(1.0 + b * b) * abs(x1 - x0)

	return abs(_F(x1, a, b) - _F(x0, a, b))
