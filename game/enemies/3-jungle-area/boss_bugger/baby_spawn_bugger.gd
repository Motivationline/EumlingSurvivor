extends BabyController

const VERTICAL_MAX_SPEED: float = 5.0

var vertical_speed: float = 0.0

func move(_delta: float) -> void:
    super(_delta)
    vertical_speed = lerpf(vertical_speed, VERTICAL_MAX_SPEED, 0.01)
    visuals.global_position.y += vertical_speed * _delta
