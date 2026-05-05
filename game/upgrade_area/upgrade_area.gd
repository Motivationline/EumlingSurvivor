## Creates an area that gives the player a temporary upgrade while inside
class_name UpgradeArea extends Area3D

@export var temporary_upgrades: Array[Upgrade] = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: CharacterBody3D):
	if not body is Player: return
	for upgrade in temporary_upgrades:
		body.upgrade_area_enter(upgrade)

func _on_body_exited(body: CharacterBody3D):
	if not body is Player: return
	for upgrade in temporary_upgrades:
		body.upgrade_area_exit(upgrade)
