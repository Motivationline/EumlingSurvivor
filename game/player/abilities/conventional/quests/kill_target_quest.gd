class_name KillTargetQuest extends Quest

@export var heal_amount: int = 50
@export var target_visuals: PackedScene

var attacks_performed: int = 0
var target: Enemy
var visuals: Node3D

func start():
	attacks_performed = 0
	choose_target()

func choose_target():
	var enemies = get_tree().get_nodes_in_group("Enemy")
	target = enemies.pick_random()
	target.died.connect(killed)
	if target_visuals:
		visuals = target_visuals.instantiate()
		target.add_child(visuals)


func killed():
	Player.player.health += heal_amount
	complete()

func precondition_is_met() -> bool:
	return true

func end():
	if target:
		target.died.disconnect(killed)
		if visuals:
			target.remove_child(visuals)
			visuals = null
		target = null
