extends MiniEumling

@export var attack_enemy_state: State
@export var follow_player: State
@export var reached_player: State

func _ready() -> void:
	super()
	Player.player.hit.connect(attack_enemy)
	reached_player.entered.connect(reset_enemy)

var current_enemy: Enemy

func attack_enemy(enemy: Enemy):
	if current_enemy: return
	if enemy.health <= 0: return
	if current_enemy == enemy: return
	attack_enemy_state.target_entity = enemy
	state_machine.switch_to_state(attack_enemy_state)

	if not enemy.died.is_connected(stop_attacking_enemy):
		enemy.died.connect(stop_attacking_enemy)
	current_enemy = enemy

func stop_attacking_enemy():
	state_machine.switch_to_state(follow_player)
	if current_enemy:
		current_enemy.died.disconnect(stop_attacking_enemy)

func reset_enemy():
	current_enemy = null
