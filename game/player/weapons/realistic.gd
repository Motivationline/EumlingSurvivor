extends Weapon

class_name Realistic

## in attacks per second
@export var base_attack_speed: float = 1
@export var base_range: float = 5
@export var base_damage: float = 1
@export var base_projectile_amount: int = 1
@export var base_projectile_speed: float = 2
@export var base_piercing: int = 0


@onready var entity_spawner: EntitySpawner = $EntitySpawner
@onready var attack_timer: Timer = $AttackTimer
@onready var spawn_anchor: Marker3D = $SpawnAnchor
# custom stuff for custom upgrades
@onready var entity_spawner_backwards: EntitySpawner = $EntitySpawnerBackwards
const REALISTIC_PROJECTILE_WITH_AOE = preload("uid://bxtdvm2y2dpcx")

var possible_unique_upgrades: Array[Upgrade] = [
	CustomUpgrade.new("shoot_backwards"),
	CustomUpgrade.new("aoe_arrows"),
]

var active_unique_upgrades: Array[String] = []

func _ready() -> void:
	base_type = Enum.EUMLING_TYPE.REALISTIC

	possible_playstyle_upgrades = [Enum.EUMLING_TYPE.SOCIAL, Enum.EUMLING_TYPE.ENTERPRISING, Enum.EUMLING_TYPE.INVESTIGATIVE]

	possible_upgrades = [
		Upgrade.new(Enum.UPGRADE.RANGE, Enum.UPGRADE_METHOD.MULTIPLIER, 1.25),
		Upgrade.new(Enum.UPGRADE.ATTACK_SPEED, Enum.UPGRADE_METHOD.MULTIPLIER, 1.1),
		Upgrade.new(Enum.UPGRADE.ATTACK_SPEED, Enum.UPGRADE_METHOD.MULTIPLIER, 1.2),
		Upgrade.new(Enum.UPGRADE.ATTACK_SPEED, Enum.UPGRADE_METHOD.MULTIPLIER, 1.5),
		Upgrade.new(Enum.UPGRADE.DAMAGE, Enum.UPGRADE_METHOD.MULTIPLIER, 1.1),
		Upgrade.new(Enum.UPGRADE.DAMAGE, Enum.UPGRADE_METHOD.MULTIPLIER, 1.2),
		Upgrade.new(Enum.UPGRADE.DAMAGE, Enum.UPGRADE_METHOD.MULTIPLIER, 1.5),
		Upgrade.new(Enum.UPGRADE.DAMAGE, Enum.UPGRADE_METHOD.ABSOLUTE, 1),
		Upgrade.new(Enum.UPGRADE.DAMAGE, Enum.UPGRADE_METHOD.ABSOLUTE, 2),
		Upgrade.new(Enum.UPGRADE.DAMAGE, Enum.UPGRADE_METHOD.ABSOLUTE, 5),
		Upgrade.new(Enum.UPGRADE.PROJECTILE_AMOUNT, Enum.UPGRADE_METHOD.ABSOLUTE, 1),
		Upgrade.new(Enum.UPGRADE.PROJECTILE_SPEED, Enum.UPGRADE_METHOD.MULTIPLIER, 1.1),
		Upgrade.new(Enum.UPGRADE.PROJECTILE_SPEED, Enum.UPGRADE_METHOD.MULTIPLIER, 1.2),
		Upgrade.new(Enum.UPGRADE.PROJECTILE_SPEED, Enum.UPGRADE_METHOD.MULTIPLIER, 1.5),
		Upgrade.new(Enum.UPGRADE.PIERCING, Enum.UPGRADE_METHOD.ABSOLUTE, 1),
	]


func setup(_player: Player):
	super (_player)

	# pass through and set up relevant variables
	entity_spawner.amount_of_spawns = base_projectile_amount
	attack_timer.wait_time = 1 / base_attack_speed
	_player.add_upgrade(Upgrade.new(Enum.UPGRADE.DAMAGE, Enum.UPGRADE_METHOD.ABSOLUTE, base_damage))
	_player.add_upgrade(Upgrade.new(Enum.UPGRADE.RANGE, Enum.UPGRADE_METHOD.ABSOLUTE, base_range))
	_player.add_upgrade(Upgrade.new(Enum.UPGRADE.PROJECTILE_SPEED, Enum.UPGRADE_METHOD.ABSOLUTE, base_projectile_speed))
	_player.add_upgrade(Upgrade.new(Enum.UPGRADE.PIERCING, Enum.UPGRADE_METHOD.ABSOLUTE, base_piercing))

	# setup listeners
	attack_timer.timeout.connect(attack)

func attack():
	entity_spawner.spawn(player, spawn_anchor)
	if (active_unique_upgrades.has("shoot_backwards")):
		entity_spawner_backwards.spawn(player, spawn_anchor)

func upgrade_added(_upgrade: Upgrade) -> void:
	match _upgrade.type:
		Enum.UPGRADE.ATTACK_SPEED:
			attack_timer.wait_time = 1 / Upgrade.apply_all(base_attack_speed, player.get_upgrades_for(Enum.UPGRADE.ATTACK_SPEED))
		Enum.UPGRADE.PROJECTILE_AMOUNT:
			prints(base_projectile_amount, Upgrade.apply_all(base_projectile_amount, player.get_upgrades_for(Enum.UPGRADE.PROJECTILE_AMOUNT)))
			entity_spawner.amount_of_spawns = int(Upgrade.apply_all(base_projectile_amount, player.get_upgrades_for(Enum.UPGRADE.PROJECTILE_AMOUNT)))
		Enum.UPGRADE.CUSTOM:
			if (_upgrade is CustomUpgrade):
				custom_upgrade_added(_upgrade)

func custom_upgrade_added(_upgrade: CustomUpgrade):
	if (!possible_unique_upgrades.has(_upgrade)): return
	
	possible_unique_upgrades.remove_at(possible_unique_upgrades.find(_upgrade))
	active_unique_upgrades.append(_upgrade.custom)

	match _upgrade.custom:
		"aoe_arrows":
			entity_spawner.entity_to_spawn = REALISTIC_PROJECTILE_WITH_AOE
			entity_spawner_backwards.entity_to_spawn = REALISTIC_PROJECTILE_WITH_AOE

func get_playstyle_upgrades():
	return []

func get_possible_upgrades():
	var upgrades = possible_upgrades.duplicate()
	upgrades.append_array(possible_unique_upgrades)
	return upgrades

func physics_process(_delta: float) -> void:
	pass
func process(_delta: float) -> void:
	pass
