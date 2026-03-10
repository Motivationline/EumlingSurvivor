extends Ability

## How long after a vulerability zone was triggered should another one appear?
@export var reappear_time_base: float = 4
## Multiplier to the base reappearing time, applied per [u]additional[/u] eumling.
## 0.9 = 90% = 10% time reduction
@export_range(0.1, 0.99) var reappear_time_multiplier: float = 0.9
## Ensure the reappear time can never fall below this
@export var minimum_reappear_time: float = 1

## How many degrees should the base weakspot have?
@export_range(0, 360) var weakspot_size_base: int = 20
## Weakspots additional size per additional eumling 
@export_range(0, 360) var weakspot_size_additional: int = 20

## How much more damage should a projectile do if it hits the weakspot?
# @export var damage_multiplier: float = 2.0

var degrees: float: 
	get(): 
		return weakspot_size_base + (amt_eumlings - 1) * weakspot_size_additional
var cooldown: float: 
	get(): 
		return max(minimum_reappear_time, reappear_time_base * pow(reappear_time_multiplier, (amt_eumlings - 1)))

func _ready() -> void:
	_type = Enum.EUMLING_TYPE.INVESTIGATIVE
	super ()

func _process(_delta: float) -> void:
	pass

func _update():
	var enemies = get_tree().get_nodes_in_group("Enemy") as Array[Enemy]
	if amt_eumlings == 0:
		# disable all existing weakspots
		for enemy in enemies:
			enemy.vulnerability_display.enabled = false
		return
	for enemy in enemies:
		enemy.vulnerability_display.degrees = degrees
		enemy.vulnerability_display.cooldown = cooldown
		if not enemy.vulnerability_display.enabled:
			enemy.vulnerability_display.enabled = true
