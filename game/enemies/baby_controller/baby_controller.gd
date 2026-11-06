class_name BabyController extends Node3D

##The visuals to spawn
@export var visuals: Node3D
##The time it takes for the visuals to shrink
@export var timeout: float = 4.0
@export var speed: float = 1.0
##The curve controlling shrinking
@export var shrink_curve: Curve

@export var timer: Timer


var direction: Vector3 = Vector3.FORWARD


func _ready() -> void:
	direction = direction.rotated(Vector3.UP, randf_range(0, 2 * PI))
	visuals.look_at(direction)

	timer.wait_time = timeout
	timer.timeout.connect(on_timer_done)
	timer.start()
	

func _physics_process(_delta: float) -> void:
	move(_delta)
	shrink()
	

func move(_delta: float) -> void:
	visuals.global_position += direction * speed * _delta


func shrink() -> void:
	visuals.scale = Vector3(1, 1, 1) * max(shrink_curve.sample(1 - timer.time_left / timeout), 0.01)
	
	print(visuals.scale)

func on_timer_done() -> void:
	queue_free()
