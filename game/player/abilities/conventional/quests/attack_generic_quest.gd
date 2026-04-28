class_name AttackGenericQuest extends Quest

@export var attack_amount_required: int = 8

var attacks_performed: int = 0

func start():
	Player.player.attacked.connect(attacked)
	attacks_performed = 0
	progress.emit(attacks_performed, attack_amount_required)


func attacked():
	attacks_performed += 1
	progress.emit(attacks_performed, attack_amount_required)
	if attacks_performed >= attack_amount_required:
		complete()

func precondition_is_met() -> bool:
	return true

func end():
	if Player.player.attacked.is_connected(attacked):
		Player.player.attacked.disconnect(attacked)
