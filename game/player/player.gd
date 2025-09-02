extends CharacterBody3D


@export var speed := 5.0


func _physics_process(_delta: float) -> void:
	var direction = Input.get_vector("left", "right", "up", "down")
	var direction_3d = Vector3(direction.x, 0, direction.y)
	velocity = direction_3d * speed
	move_and_slide()

	look_at(global_position + direction_3d)
