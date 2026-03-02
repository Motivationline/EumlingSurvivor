extends Node3D
class_name StatusVisuals

## Should the health numbers be visible?
@export var show_health_numbers: bool = false

@onready var healthbar: Healthbar = $SubViewport/Healthbar

func _ready():
	healthbar.show_health_numbers = show_health_numbers

var health: float = 0:
	set = _set_health
var max_health: float = 0:
	set = _set_max_health


func init_health(_health: float):
	health = _health
	healthbar.init_health(health)

func _set_health(value: float):
	health = value
	if (healthbar): healthbar.health = health

func _set_max_health(value: float):
	max_health = value
	if (healthbar): healthbar.max_health = max_health
