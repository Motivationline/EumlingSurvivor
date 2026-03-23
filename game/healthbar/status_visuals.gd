extends Node3D
class_name StatusVisuals

## Should the health numbers be visible?
@export var show_health_numbers: bool = false

var healthbars: Array[Healthbar] = []

func _ready():
	healthbars.append($SubViewport/Healthbar)
	for healthbar in healthbars:
		healthbar.show_health_numbers = show_health_numbers

var health: float = 0:
	set = _set_health
var max_health: float = 0:
	set = _set_max_health


func init_health(_health: float):
	health = _health
	for healthbar in healthbars:
		healthbar.init_health(health)

func _set_health(value: float):
	health = value
	for healthbar in healthbars:
		healthbar.health = health

func _set_max_health(value: float):
	max_health = value
	for healthbar in healthbars:
		healthbar.max_health = max_health
