extends Weapon

class_name Realistic

## in attacks per second
@export var base_attack_speed: float
@export var base_range: float
@export var base_damage: float
@export var base_projectile_amount: int
@export var base_projectile_speed: int
@export var base_piercing: int


@onready var entity_spawner: EntitySpawner = $EntitySpawner

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
		Upgrade.new(Enum.UPGRADE.SIZE, Enum.UPGRADE_METHOD.MULTIPLIER, 1.1),
		Upgrade.new(Enum.UPGRADE.SIZE, Enum.UPGRADE_METHOD.MULTIPLIER, 1.2),
		Upgrade.new(Enum.UPGRADE.SIZE, Enum.UPGRADE_METHOD.MULTIPLIER, 1.5),
		Upgrade.new(Enum.UPGRADE.PROJECTILE_AMOUNT, Enum.UPGRADE_METHOD.ABSOLUTE, 1),
		Upgrade.new(Enum.UPGRADE.PROJECTILE_SPEED, Enum.UPGRADE_METHOD.MULTIPLIER, 1.1),
		Upgrade.new(Enum.UPGRADE.PROJECTILE_SPEED, Enum.UPGRADE_METHOD.MULTIPLIER, 1.2),
		Upgrade.new(Enum.UPGRADE.PROJECTILE_SPEED, Enum.UPGRADE_METHOD.MULTIPLIER, 1.5),
		Upgrade.new(Enum.UPGRADE.PIERCING, Enum.UPGRADE_METHOD.ABSOLUTE, 1),
	]

func get_playstyle_upgrades():
	return []

func get_possible_upgrades():
	return possible_upgrades

func physics_process(_delta: float) -> void:
	pass
