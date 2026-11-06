class_name BabyController extends Node3D
##Container for a enemy to be spawned by an [EntitySpawner]

##The time it takes for the visuals to shrink
@export var timeout: float = 4.0
##The movement speed of the baby
@export var speed: float = 1.0
##The curve controlling shrinking
@export var shrink_curve: Curve
##Timer node
@export var timer: Timer
##Container for 3D Model. Add the model as a child of this
@export var visuals: Node3D

##The movement direction, decided at random
var direction: Vector3 = Vector3.FORWARD


func _ready() -> void:
	direction = direction.rotated(Vector3.UP, randf_range(0, 2 * PI))
	visuals.look_at(direction)

	timer.wait_time = timeout
	timer.timeout.connect(queue_free)
	timer.start()
	

func _physics_process(_delta: float) -> void:
	move(_delta)
	shrink()
	
##Moves the visuals forward
func move(_delta: float) -> void:
	visuals.global_position += direction * speed * _delta

##Shrinks the visuals based on the curve and time3
func shrink() -> void:
	visuals.scale = Vector3(1, 1, 1) * max(shrink_curve.sample(1 - timer.time_left / timeout), 0.01)
