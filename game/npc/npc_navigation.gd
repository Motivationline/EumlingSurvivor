extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

@export var speed: float = 5.0

	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		var random_position := Vector3.ZERO
		random_position.x = randf_range(-10, 10)
		random_position.z = randf_range(-10, 10)
		navigation_agent_3d.target_position = random_position

func _physics_process(_delta: float) -> void:
	if(navigation_agent_3d.is_navigation_finished()): return
	var destination = navigation_agent_3d.get_next_path_position()
	var local_destination = destination - global_position
	var direction = local_destination.normalized()
	velocity = direction * speed
	move_and_slide()
