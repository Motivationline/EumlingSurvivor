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
# @export var upgrades: Array[UpgradeStrategy]

@export_category("Event Listeners")
@export var on_death: Array[EventStrategy]
@export var on_hit: Array[EventStrategy]
@export var on_hurt: Array[EventStrategy]

var max_health: float

func _ready() -> void:
	max_health = health
	if (healthbar): healthbar.init_health(max_health)
	if (hitbox): hitbox.hit.connect(_hit)
	if (hurtbox): hurtbox.hurt_by.connect(_hurt_by)

	Strategy._setup_array(movement, self)
	Strategy._setup_array(on_death, self)
	Strategy._setup_array(on_hit, self)
	Strategy._setup_array(on_hurt, self)

	add_to_group("Enemy")

func _hit(_attacker: HurtBox):
	pass

func _hurt_by(_attackee: HitBox):
	pass

func _physics_process(_delta: float) -> void:
	var direction := Vector3.ZERO
	for mov in movement:
		direction = mov.get_movement_direction(direction)
	velocity = direction
	move_and_slide()
