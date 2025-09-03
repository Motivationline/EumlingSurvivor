extends Node3D
class_name Healthbar3D

@onready var damage_bar: ProgressBar = $SubViewport/Control/DamageBar
@onready var health_bar: ProgressBar = $SubViewport/Control/HealthBar
@onready var timer: Timer = $Timer


var health: float = 0:
	set = _set_health

func init_health(_health: float):
	health = _health
	damage_bar.max_value = _health
	damage_bar.value = _health
	health_bar.max_value = _health
	health_bar.value = _health

func _set_health(value: float):
	var prev_health = health
	health = value
	health_bar.value = health
	
	if (health > prev_health):
		damage_bar.value = health
	else:
		timer.start()

func _on_timer_timeout() -> void:
	damage_bar.value = health
