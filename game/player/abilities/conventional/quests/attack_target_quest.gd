class_name AttackTargetQuest extends Quest

@export var attack_amount_required: int = 1
@export var target_visuals: PackedScene

var attacks_performed: int = 0
var target: Enemy
var visuals: Node3D

func start():
	attacks_performed = 0
	progress.emit(attacks_performed, attack_amount_required)
	choose_target()

func choose_target():
	var enemies = get_tree().get_nodes_in_group("Enemy")
	target = enemies.pick_random()
	target.hurt.connect(attacked)
	target.died.connect(killed)
	if target_visuals:
		visuals = target_visuals.instantiate()
		target.add_child(visuals)

func attacked():
	attacks_performed += 1
	progress.emit(attacks_performed, attack_amount_required)
	if attacks_performed >= attack_amount_required:
		complete()

func killed():
	if not done:
		choose_target()

func precondition_is_met() -> bool:
	var enemies = get_tree().get_nodes_in_group("Enemy")
	return enemies.size() > 0

func end():
	if target:
		target.hurt.disconnect(attacked)	
		target.died.disconnect(killed)
		if visuals:
			target.remove_child(visuals)
			visuals = null
		target = null
