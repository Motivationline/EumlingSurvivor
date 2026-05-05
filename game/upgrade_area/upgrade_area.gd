## Creates an area that gives the player a temporary upgrade while inside
class_name UpgradeArea extends Area3D

## What upgrades should the player get while in this area?
@export var temporary_upgrades: Array[Upgrade] = []
## How long before the effect takes place after entering the area
@export var enter_delay: float = 0.0
## How long before the effect is removed again after leaving the area
@export var exit_delay: float = 0.0

var enter_timer: Timer
var exit_timer: Timer

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	enter_timer = Timer.new()
	exit_timer = Timer.new()
	enter_timer.one_shot = true
	exit_timer.one_shot = true
	add_child(enter_timer)
	add_child(exit_timer)
	enter_timer.timeout.connect(_on_entered_timer_completed)
	exit_timer.timeout.connect(_on_exited_timer_completed)

func _on_body_entered(body: CharacterBody3D):
	if not body is Player: return
	if enter_delay > 0:
		enter_timer.start(enter_delay)
	else:
		_on_entered_timer_completed()

func _on_body_exited(body: CharacterBody3D):
	if not body is Player: return
	if not enter_timer.is_stopped():
		enter_timer.stop()
		return
	if exit_delay > 0:
		exit_timer.start(exit_delay)
	else:
		_on_exited_timer_completed()

func _on_entered_timer_completed():
	for upgrade in temporary_upgrades:
		Player.player.upgrade_area_enter(upgrade)
func _on_exited_timer_completed():
	for upgrade in temporary_upgrades:
		Player.player.upgrade_area_exit(upgrade)
