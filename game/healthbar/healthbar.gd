extends Control
class_name Healthbar

@onready var damage_bar: ProgressBar = $DamageBar
@onready var health_bar: ProgressBar = $HealthBar
@onready var health_points_display: Label = $HealthPointsDisplay
@onready var timer: Timer = $Timer

## Hides the healthbar after this time if it's full. Set to negative to always show.
@export var hide_when_full_after: float = 2.0
## Whether to hide the healthbar initially
@export var hide_initially: bool = true
## Should the health numbers be visible?
@export var show_health_numbers: bool = false:
	set(value):
		show_health_numbers = value	
		health_points_display.visible = show_health_numbers


var health: float = 0:
	set = _set_health
var max_health: float = 0:
	set = _set_max_health
	
func _ready():
	health_points_display.visible = show_health_numbers

func _set_health(value: float):
	var prev_health = health
	health = value
	health_points_display.text = str(int(health))
	if (health_bar):
		var health_tween = create_tween()
		health_tween.tween_property(health_bar, "value", health, 0.05)

	
	if (health > prev_health):
		if (damage_bar): damage_bar.value = health
	else:
		timer.start()
	
	if (health_bar && health_bar.max_value == health && hide_when_full_after >= 0):
		await get_tree().create_timer(hide_when_full_after).timeout
		if (health_bar.max_value == health && hide_when_full_after >= 0):
			visible = false
	else:
		visible = true

func _set_max_health(value: float):
	max_health = value
	damage_bar.max_value = value
	health_bar.max_value = value

func _on_timer_timeout() -> void:
	var damage_tween = create_tween()
	damage_tween.tween_property(damage_bar, "value", health, 0.1)

func init_health(_health: float):
	health = _health
	damage_bar.value = _health
	health_bar.value = _health
	max_health = _health
	if (hide_initially):
		visible = false
