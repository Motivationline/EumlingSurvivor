extends CharacterBody3D
class_name Projectile

@export_category("Base Values")

## How much (base) damage this bullet does. May be modified by upgrades or attacks
@export var damage: float = 2.0:
	set(new_dmg):
		damage = new_dmg
		if (hit_box): hit_box.damage = new_dmg
## How long this bullet lives at most
@export var lifetime: float = 2.0

@export_category("Base Functionality")
@export var hit_box: HitBox
@export var hurt_box: HurtBox

@export_category("Extended Functionality")
@export var movement: Array[ProjectileMovementStrategy]
var movement_instance
@export var upgrades: Array[UpgradeStrategy]
var upgrades_instance

@export_category("Event Listeners")
@export var on_world_collision: Array[EventStrategy]
@export var on_hit: Array[EventStrategy]
@export var on_hurt: Array[EventStrategy]
@export var on_end_of_life: Array[EventStrategy]

var current_lifetime: float = 0
var target_position: Vector3

func setup(_owner: Enum.GROUP, pos: Vector3, rot: Vector3, target_pos: Vector3, _upgrades: Array[UpgradeStrategy] = []):
	target_position = target_pos
	if (hit_box):
		hit_box.damage = damage
		hit_box.hit.connect(_hit_box_hit)
		if (_owner == Enum.GROUP.PLAYER):
			hit_box.can_hit = Enum.HURTBOX.ENEMY
			hit_box.attached_to = Enum.HITBOX.PLAYER
		elif (_owner == Enum.GROUP.ENEMY):
			hit_box.can_hit = Enum.HURTBOX.PLAYER
			hit_box.attached_to = Enum.HITBOX.ENEMY
	global_position = pos
	global_position.y = 1 # TODO: this probably needs to change
	global_rotation = rot
	upgrades.append_array(_upgrades)

	movement_instance = Strategy.setupArray(movement, self)
	upgrades_instance = Strategy.setupArray(upgrades, self)
	# on_world_collision = Strategy.setupArray(on_world_collision, self)
	# on_hit = Strategy.setupArray(on_hit, self)
	# on_hurt = Strategy.setupArray(on_hurt, self)
	# on_end_of_life = Strategy.setupArray(on_end_of_life, self)

func _ready() -> void:
	await get_tree().create_timer(lifetime).timeout
	await _end_of_lifetime()
	queue_free()

func _physics_process(delta: float) -> void:
	current_lifetime += delta
	for mov in movement_instance:
		mov.apply_movement(self, current_lifetime / lifetime)
	velocity *= delta
	move_and_collide(velocity)

func _end_of_lifetime():
	for strat in on_end_of_life:
		await strat.execute(self)

func _hit_box_hit():
	pass

# TODO: by default, fly through everything
