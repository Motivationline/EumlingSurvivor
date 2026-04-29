extends StateMachinePoweredEntity

@export var attack_enemy_state: State
@export var follow_player: State

@onready var visuals: Node3D = $Visuals

func _ready() -> void:
	super()
	Player.player.hit.connect(attack_enemy)

var current_enemy: Enemy

func attack_enemy(enemy: Enemy):
	
	if enemy.health <= 0: return
	if current_enemy == enemy: return
	attack_enemy_state.fixed_target = enemy
	state_machine.switch_to_state(attack_enemy_state)
	if current_enemy:
		current_enemy.died.disconnect(enemy_died)
	current_enemy = enemy
	current_enemy.died.connect(enemy_died)

func enemy_died():
	state_machine.switch_to_state(follow_player)
