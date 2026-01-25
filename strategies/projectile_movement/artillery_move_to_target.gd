extends ProjectileMovementStrategy
## Moves the projectile in a parabolic way
class_name ArtilleryToTargetProjectileMovementStrategy

## amount to rotate when directions change
@export_range(0.0,20.0,0.1) var rotation_speed: float = 15
## how quick the direction of the velocity changes (grater values = faster)
@export_range(0.0,50,0.1) var velocity_change_rate: float = 30

@export var speed_amp: float = 10

@onready var db_cube: MeshInstance3D = $"../../DBMesh"

var isPosLocked: bool = false
var start_pos: Vector3
var target_pos: Vector3
var distance: float
var traveled: float

func _setup(_parent: Node, _owner: Node):
	super (_parent, _owner)
	start_pos = parent.position
	parent.velocity = Vector3.ZERO


#TODO: estimate enemy position when projectile hits and correct it's path

func apply_movement(_delta: float, _current_lifetime: float, _total_lifetime: float):
	#checks if the projectile is fired from the player and adjusts the target accordingly
	if len(parent.get_targets()) > 0:
		var target = parent.get_targets()[0]
		#print("Target: ", target)
		if target:
			#var speed_mag = parent.velocity.length()
			var new_dir = lerp(parent.velocity.normalized(), (target.position - parent.position).normalized(), _delta * velocity_change_rate)
			#parent.velocity = lerp(parent.velocity, (target.position - parent.position).normalized() * speed, _delta * rotation_speed)
			
			#parabula y = x/z
			#line: player -> targetpos
			
			if not isPosLocked:
				target_pos = target.position
				distance = (target_pos - start_pos).length()
				isPosLocked = true
				print("distance:", distance)
				#target_pos.y = 0
				#start_pos.y = 0
			
			db_cube.global_position = target_pos
			
			var parent_pos = parent.position
			#parent_pos.y = 0
			
			traveled = ((start_pos - Vector3(0,start_pos.y,0))- (parent_pos - Vector3(0,parent_pos.y,0))).length()
			print("traveled: ",traveled, " start_pos: ", start_pos, " target_pos: ", target_pos, " parent_pos: ", parent.global_position)
			# x is the amount we already traveled in target position
			var x = traveled
			# calculate the y-pos for x (how far we traveled to the target) on the parabula
			# the parabula ranges from start_pos to target_pos
			var arc_factor = 2
			var y = arc_factor/distance * (-(x * x) + distance * x)
			# calculate the gradient (steigung) at a certain point
			# we can use the gradient to calculate the angle our projectile should be at on every point
			var gradient = arc_factor/distance * (- 2*x + distance)
			
			#parent.velocity = new_dir #* speed_mag
			
			
			# horizontal direction from start to target
			var horizontal_dir = (target_pos - start_pos)
			horizontal_dir.y = 0
			horizontal_dir = horizontal_dir.normalized()

			# slope at current point
			var slope = gradient

			# build direction vector
			var dir = horizontal_dir + Vector3.UP * slope
			dir = dir.normalized()

			#var speed = parent.velocity.length()
			parent.velocity = dir * speed_amp
			
			#print("velocity: ", parent.velocity, ", new_dir: ", new_dir, ", speed_mag: ", speed_mag)
			#parent.position.y = y
			#parent.rotation.y = tan(1/gradient)
			#parent.rotation.x = lerp_angle(parent.rotation.x, atan2(-parent.velocity.y, -parent.velocity.z), _delta * rotation_speed)
