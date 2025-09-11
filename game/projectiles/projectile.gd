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
# @export var upgrades: Array[UpgradeStrategy]

@export_category("Event Listeners")
@export var on_world_collision: Array[EventStrategy]
@export var on_hit: Array[EventStrategy]
@export var on_hurt: Array[EventStrategy]
@export var on_end_of_life: Array[EventStrategy]
@export var on_remove: Array[EventStrategy]

var current_lifetime: float = 0
var target_position: Vector3

func setup(target_pos: Vector3, _upgrades: Array[UpgradeStrategy] = []):
	target_position = target_pos
	if (hit_box):
		hit_box.damage = damage
		hit_box.hit.connect(_hit_box_hit)
	if (hurt_box):
		hurt_box.hurt_by.connect(_hurt_box_hurt)

	Strategy._setup_array(movement, self)
	Strategy._setup_array(on_world_collision, self)
	Strategy._setup_array(on_hit, self)
	Strategy._setup_array(on_hurt, self)
	Strategy._setup_array(on_end_of_life, self)
	Strategy._setup_array(on_remove, self)

func _ready() -> void:
	tree_exiting.connect(_on_remove)
	await get_tree().create_timer(lifetime).timeout
	await _end_of_lifetime()
	queue_free()

func _physics_process(delta: float) -> void:
	current_lifetime += delta
	for mov in movement:
		mov.apply_movement(delta, current_lifetime, lifetime)
	velocity *= delta
	var collision: KinematicCollision3D = move_and_collide(velocity)
	if (collision):
		for coll in on_world_collision:
			coll.event_triggered(collision)


func _end_of_lifetime():
	for strat in on_end_of_life:
		await strat.event_triggered(null)

func _on_remove():
	for strat in on_remove:
		strat.event_triggered(null)

func _hit_box_hit(_area):
	for ev in on_hit:
		ev.event_triggered(_area)
func _hurt_box_hurt(_area):
	for ev in on_hurt:
		ev.event_triggered(_area)
