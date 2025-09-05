extends CharacterBody3D
class_name Enemy

@export_category("Base Values")

## How much (max)health this entity has. May be modified by upgrades.
@export var health: float:
	set(new_value):
		health = new_value
		if (healthbar): healthbar.health = health
		# TODO: add damage number popup

@export_category("Base Functionality")
@export var healthbar: Healthbar3D
@export var hitbox: HitBox
@export var hurtbox: HurtBox

@export_category("Extended Functionality")
@export var movement: Array[EnemyMovementStrategy]
var movement_local
@export var attacks: Array[AttackStrategy]
var attacks_local
@export var upgrades: Array[UpgradeStrategy]
var upgrades_local

@export_category("Event Listeners")
@export var on_death: Array[EventStrategy]
var on_death_local
@export var on_hit: Array[EventStrategy]
var on_hit_local
@export var on_hurt: Array[EventStrategy]
var on_hurt_local

var max_health: float

func _ready() -> void:
	max_health = health
	if (healthbar): healthbar.init_health(max_health)
	if (hitbox): hitbox.hit.connect(_hit)
	if (hurtbox): hurtbox.hurt_by.connect(_hurt_by)

	movement_local = Strategy.setupArray(movement, self)
	attacks_local = Strategy.setupArray(attacks, self)
	upgrades_local = Strategy.setupArray(upgrades, self)
	on_death_local = Strategy.setupArray(on_death, self)
	on_hit_local = Strategy.setupArray(on_hit, self)
	on_hurt_local = Strategy.setupArray(on_hurt, self)

	add_to_group("Enemy")

func _hit(_attacker: HurtBox):
	pass

func _hurt_by(_attackee: HitBox):
	pass

func _physics_process(_delta: float) -> void:
	var direction := Vector3.ZERO
	for mov in movement_local:
		direction = mov.get_movement_direction(direction)
	velocity = direction
	move_and_slide()
