extends Node3D
class_name Healthbar3D

## Hides the healthbar after this time if it's full. Set to negative to always show.
@export var hide_when_full_after: float = 2.0
## Whether to hide the healthbar initially
@export var hide_initially: bool = true

@onready var healthbar: Healthbar = $SubViewport/Healthbar

func _ready():
	healthbar.hide_when_full_after = hide_when_full_after
	healthbar.hide_initially = hide_initially

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
