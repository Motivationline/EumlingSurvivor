extends Node3D
class_name Healthbar3D

@onready var damage_bar: ProgressBar = $SubViewport/Control/DamageBar
@onready var health_bar: ProgressBar = $SubViewport/Control/HealthBar
@onready var timer: Timer = $Timer

## Hides the healthbar after this time if it's full. Set to negative to always show.
@export var hide_when_full_after: float = 2.0
## Whether to hide the healthbar initially
@export var hide_initially: bool = true

var health: float = 0:
	set = _set_health

func init_health(_health: float):
	health = _health
	damage_bar.max_value = _health
	damage_bar.value = _health
	health_bar.max_value = _health
	health_bar.value = _health
	if (hide_initially):
		visible = false

func _set_health(value: float):
	var prev_health = health
	health = value
	health_bar.value = health
	
	if (health > prev_health):
		damage_bar.value = health
	else:
		timer.start()
	
	if (health_bar.max_value == health && hide_when_full_after >= 0):
		await get_tree().create_timer(hide_when_full_after).timeout
		if (health_bar.max_value == health && hide_when_full_after >= 0):
			visible = false
	else:
		visible = true

func _on_timer_timeout() -> void:
	damage_bar.value = health
