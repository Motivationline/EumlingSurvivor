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

@export var targeting: Array[ProjectileTargetStrategy]

@export_category("Event Managers")
@export var timeout_event_managers: Array[TimeoutEventManager]

@export_category("Event Listeners")
@export var on_world_collision: Array[EventStrategy]
@export var on_hit: Array[EventStrategy]
@export var on_hurt: Array[EventStrategy]
@export var on_end_of_life: Array[EventStrategy]
@export var on_remove: Array[EventStrategy]
@export var on_created: Array[EventStrategy]

var current_lifetime: float = 0
var target_position: Vector3

var obj_that_spawned_this: Node3D

func setup(target_pos: Vector3, _owner: Node3D):
	target_position = target_pos
	if (hit_box):
		hit_box.damage = damage
		hit_box.hit.connect(_hit_box_hit)
	if (hurt_box):
		hurt_box.hurt_by.connect(_hurt_box_hurt)
	
	obj_that_spawned_this = _owner

	if (_owner is Player): # we need to copy all those relevant upgrades
		setup_player(_owner)

	# init strategies
	Strategy._setup_array(targeting, self, _owner)
	Strategy._setup_array(movement, self, _owner)
	Strategy._setup_array(on_world_collision, self, _owner)
	Strategy._setup_array(on_hit, self, _owner)
	Strategy._setup_array(on_hurt, self, _owner)
	Strategy._setup_array(on_end_of_life, self, _owner)
	Strategy._setup_array(on_remove, self, _owner)
	Strategy._setup_array(on_created, self, _owner)

	for t in timeout_event_managers:
		t._setup(self, _owner)
	
	_on_created()

func setup_player(player: Player):
	# speed
	var speed_upgrades = player.get_upgrades_for(Enum.UPGRADE.PROJECTILE_SPEED)
	var speed_upgrade_strategy = SpeedUpgradesProjectileMovementStrategy.new()
	speed_upgrade_strategy.upgrades = speed_upgrades
	movement.append(speed_upgrade_strategy)

	# damage
	damage = Upgrade.apply_all(0, player.get_upgrades_for(Enum.UPGRADE.DAMAGE))

	# range / lifetime
	lifetime = Upgrade.apply_all(0, player.get_upgrades_for(Enum.UPGRADE.RANGE))
	restart_timer()

	# piercing
	var piercing_amount = Upgrade.apply_all(10, player.get_upgrades_for(Enum.UPGRADE.PIERCING))
	var piercing_strat = CountdownEventStrategy.new()
	piercing_strat.count = piercing_amount + 1
	on_hit.append(piercing_strat)
	piercing_strat.event = RemoveEventStrategy.new()


func _ready() -> void:
	tree_exiting.connect(_on_remove)
	start_timer()

var timer: Timer
func start_timer():
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_end_of_lifetime)
	timer.start(lifetime)

func restart_timer():
	if (!timer): return
	timer.start(lifetime)

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
	queue_free()

func _on_remove():
	for strat in on_remove:
		strat.event_triggered(null)

func _hit_box_hit(_area):
	for ev in on_hit:
		ev.event_triggered(_area)
func _hurt_box_hurt(_area):
	for ev in on_hurt:
		ev.event_triggered(_area)

func _on_created():
	for strat in on_created:
		strat.event_triggered(null)

func _set_targets():
	for t in targeting:
		if t.isActive:
			t.find_target()

func _get_targets():
	for t in targeting:
		if t.isActive:
			return t.targets

func _add_hit(_hit: Node):
	for t in targeting:
		if t.isActive:
			t.hits.append(_hit)

func _get_hits():
	for t in targeting:
		if t.isActive:
			return t.hits

func _remove_target(_target: Node):
	for t in targeting:
		if t.isActive:
			if _target in t.targets:
				var idx = t.targets.find(_target)
				t.targets.pop_at(idx)

# func _clear_targets():
# 	for t in targeting:
# 		if t.isActive:
# 			t.targets.clear()

# func _clear_hits():
# 	for t in targeting:
# 		if t.isActive:
# 			t.hits.clear()
