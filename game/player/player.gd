@tool
extends CharacterBody3D
class_name Player

var speed: float
var health: float = 10.0:
	set(new_value):
		if health == 0 and new_value > 0:
			revive()
		if health - new_value > 0:
			anim_player.set("parameters/GetHitOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

		if (max_health <= 0):
			health = new_value
		else:
			health = clampf(new_value, 0, max_health)
		if (healthbar):
			healthbar.health = health
		if (health == 0):
			die()
var max_health: float:
	set(value):
		max_health = value
		if (healthbar):
			healthbar.max_health = max_health

signal died

# @export var weapon: Weapon

@export var eumling_visuals: Node3D
@export var spawner: EntitySpawner

@onready var healthbar: Healthbar3D = $Healthbar3D
@onready var hurtbox: HurtBox = $Hurtbox

## UI Stuff
@export var inv: Inv

## How long after being hit should the player be invulnerable
@export var invulnerability_time: float = 0.5
## What upgradeable values should the player start with
@export var starting_values: Dictionary[Enum.UPGRADE, float] = {
	Enum.UPGRADE.HEALTH: 10.0,
	Enum.UPGRADE.MOVEMENT_SPEED: 3.0,
}:
	set(new_value):
		starting_values = new_value
		update_configuration_warnings()

var _current_values: Dictionary[Enum.UPGRADE, float] = {}
func get_value(upgrade: Enum.UPGRADE) -> float:
	return _current_values.get(upgrade, 0)
signal upgrade_added
## Limits to the upgradeable values. x is minimum, y is maximum. If not specified, values can go from 0 to infinity.
@export var min_max_values: Dictionary[Enum.UPGRADE, Vector2] = {}


var possible_upgrades: Array[Upgrade] = [
	Upgrade.new(Enum.UPGRADE.MOVEMENT_SPEED, Enum.UPGRADE_METHOD.ABSOLUTE, 0.15, Enum.RARITY.COMMON),
	Upgrade.new(Enum.UPGRADE.ATTACK_COOLDOWN, Enum.UPGRADE_METHOD.MULTIPLIER, 0.1, Enum.RARITY.COMMON),
	Upgrade.new(Enum.UPGRADE.HEALTH, Enum.UPGRADE_METHOD.ABSOLUTE, 50, Enum.RARITY.COMMON),
	Upgrade.new(Enum.UPGRADE.HEALTH_REGENERATION, Enum.UPGRADE_METHOD.ABSOLUTE, 10, Enum.RARITY.COMMON),
	Upgrade.new(Enum.UPGRADE.RANGE, Enum.UPGRADE_METHOD.ABSOLUTE, 0.2, Enum.RARITY.COMMON),
	Upgrade.new(Enum.UPGRADE.DAMAGE, Enum.UPGRADE_METHOD.ABSOLUTE, 10, Enum.RARITY.COMMON),
	Upgrade.new(Enum.UPGRADE.CRIT_CHANCE, Enum.UPGRADE_METHOD.ABSOLUTE, 0.01, Enum.RARITY.COMMON),

	Upgrade.new(Enum.UPGRADE.MOVEMENT_SPEED, Enum.UPGRADE_METHOD.ABSOLUTE, 0.3, Enum.RARITY.UNCOMMON),
	Upgrade.new(Enum.UPGRADE.ATTACK_COOLDOWN, Enum.UPGRADE_METHOD.MULTIPLIER, 0.2, Enum.RARITY.UNCOMMON),
	Upgrade.new(Enum.UPGRADE.HEALTH, Enum.UPGRADE_METHOD.ABSOLUTE, 100, Enum.RARITY.UNCOMMON),
	Upgrade.new(Enum.UPGRADE.HEALTH_REGENERATION, Enum.UPGRADE_METHOD.ABSOLUTE, 20, Enum.RARITY.UNCOMMON),
	Upgrade.new(Enum.UPGRADE.RANGE, Enum.UPGRADE_METHOD.ABSOLUTE, 0.4, Enum.RARITY.UNCOMMON),
	Upgrade.new(Enum.UPGRADE.DAMAGE, Enum.UPGRADE_METHOD.ABSOLUTE, 20, Enum.RARITY.UNCOMMON),
	Upgrade.new(Enum.UPGRADE.CRIT_CHANCE, Enum.UPGRADE_METHOD.ABSOLUTE, 0.02, Enum.RARITY.UNCOMMON),
	
	Upgrade.new(Enum.UPGRADE.MOVEMENT_SPEED, Enum.UPGRADE_METHOD.ABSOLUTE, 0.4, Enum.RARITY.RARE),
	Upgrade.new(Enum.UPGRADE.ATTACK_COOLDOWN, Enum.UPGRADE_METHOD.MULTIPLIER, 0.4, Enum.RARITY.RARE),
	Upgrade.new(Enum.UPGRADE.HEALTH, Enum.UPGRADE_METHOD.ABSOLUTE, 200, Enum.RARITY.RARE),
	Upgrade.new(Enum.UPGRADE.HEALTH_REGENERATION, Enum.UPGRADE_METHOD.ABSOLUTE, 50, Enum.RARITY.RARE),
	Upgrade.new(Enum.UPGRADE.RANGE, Enum.UPGRADE_METHOD.ABSOLUTE, 0.7, Enum.RARITY.RARE),
	Upgrade.new(Enum.UPGRADE.DAMAGE, Enum.UPGRADE_METHOD.ABSOLUTE, 40, Enum.RARITY.RARE),
	Upgrade.new(Enum.UPGRADE.CRIT_CHANCE, Enum.UPGRADE_METHOD.ABSOLUTE, 0.05, Enum.RARITY.RARE),
	
	Upgrade.new(Enum.UPGRADE.MOVEMENT_SPEED, Enum.UPGRADE_METHOD.ABSOLUTE, 0.6, Enum.RARITY.EPIC),
	Upgrade.new(Enum.UPGRADE.ATTACK_COOLDOWN, Enum.UPGRADE_METHOD.MULTIPLIER, 0.6, Enum.RARITY.EPIC),
	Upgrade.new(Enum.UPGRADE.HEALTH, Enum.UPGRADE_METHOD.MULTIPLIER, 1.5, Enum.RARITY.EPIC),
	#Upgrade.new(Enum.UPGRADE.HEALTH_REGENERATION, Enum.UPGRADE_METHOD.MULTIPLIER, 1.1, Enum.RARITY.EPIC),
	Upgrade.new(Enum.UPGRADE.RANGE, Enum.UPGRADE_METHOD.ABSOLUTE, 1.2, Enum.RARITY.EPIC),
	Upgrade.new(Enum.UPGRADE.DAMAGE, Enum.UPGRADE_METHOD.MULTIPLIER, 1.4, Enum.RARITY.EPIC),
	Upgrade.new(Enum.UPGRADE.CRIT_CHANCE, Enum.UPGRADE_METHOD.ABSOLUTE, 0.12, Enum.RARITY.EPIC),
	
	Upgrade.new(Enum.UPGRADE.PROJECTILE_AMOUNT, Enum.UPGRADE_METHOD.ABSOLUTE, 1, Enum.RARITY.EPIC),
	Upgrade.new(Enum.UPGRADE.SIZE, Enum.UPGRADE_METHOD.ABSOLUTE, -1, Enum.RARITY.EPIC),
	Upgrade.new(Enum.UPGRADE.SIZE, Enum.UPGRADE_METHOD.ABSOLUTE, 1, Enum.RARITY.EPIC),
]

var anim_player: AnimationTree

@onready var attack_spawner: EntitySpawner = $DefaultAttack/AttackSpawner
@onready var attack_cooldown: Timer = $DefaultAttack/AttackCooldown
@onready var reload_progress: TextureProgressBar = $UI/Control/ReloadProgress

@onready var hurtbox_collision: CollisionShape3D = $Hurtbox/HurtboxCollision
var hurtbox_start_sizes: Vector2 = Vector2()

func _validate_property(property: Dictionary) -> void:
	if property.name == "starting_values":
		_get_configuration_warnings()

var initial_preview_color: Color

func _ready() -> void:
	if Engine.is_editor_hint(): return
	add_to_group("Player")
	hurtbox_start_sizes.x = hurtbox_collision.shape.radius
	hurtbox_start_sizes.y = hurtbox_collision.shape.height

	anim_player = eumling_visuals.find_child("AnimationTree")
	
	reload_progress.max_value = 1
	reload_progress.step = 0

	attack_cooldown.timeout.connect(reset_preview_color)
	initial_preview_color = %ShittyVisual.get_child(0).material_override.albedo_color

	reset()

# reset player to its un-upgraded state
func reset():
	_current_values = starting_values.duplicate()
	max_health = get_value(Enum.UPGRADE.HEALTH)
	health = get_value(Enum.UPGRADE.HEALTH)
	speed = get_value(Enum.UPGRADE.MOVEMENT_SPEED)

	if (healthbar): healthbar.init_health(max_health)
	if (hurtbox and not hurtbox.hurt_by.is_connected(hurt_by)): hurtbox.hurt_by.connect(hurt_by)
	eumling_visuals.scale = Vector3.ONE * get_value(Enum.UPGRADE.SIZE)
	
	attack_spawner.amount_of_spawns = int(get_value(Enum.UPGRADE.PROJECTILE_AMOUNT))

	update_attack_visual()

var is_invulnerable: bool = false
func hurt_by(_area: HitBox):
	if is_invulnerable: return
	if health == 0: return
	health -= _area.damage

	invulnerability()
	# more hit impact with some time slowdown
	if (_area.damage > 0):
		Engine.time_scale = 0.3
		await get_tree().create_timer(0.06, true, true, true).timeout
		Engine.time_scale = 1

func invulnerability():
	is_invulnerable = true
	await get_tree().create_timer(invulnerability_time, true).timeout
	is_invulnerable = false


var prev_direction: Vector3
var was_looking_somewhere: bool = false
var camera: Camera3D

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	if health == 0: return
	var direction = Input.get_vector("left", "right", "up", "down")
	var direction_3d = Vector3(direction.x, 0, direction.y)
	if camera:
		direction_3d = direction_3d.rotated(Vector3.UP, camera.rotation.y)
	velocity = direction_3d * speed
	move_and_slide()

	if not direction_3d.is_zero_approx():
		prev_direction = direction_3d
	
	anim_player.set("parameters/Idle-Walk/blend_amount", direction_3d.length())

	
	var look_direction = Input.get_vector("attack_left", "attack_right", "attack_up", "attack_down")
	var look_direction_3d = Vector3(look_direction.x, 0, look_direction.y)
	if camera:
		look_direction_3d = look_direction_3d.rotated(Vector3.UP, camera.rotation.y)
	if Input.is_action_pressed("fire") or Input.get_action_strength("fire_axis") > 0.5:
		shoot()
	if look_direction.is_zero_approx():
		if was_looking_somewhere and Data.is_on_mobile:
			shoot()
		was_looking_somewhere = false
		if not prev_direction.is_zero_approx():
			eumling_visuals.look_at(global_position + prev_direction)
		%ShittyVisual.hide()
	else:
		eumling_visuals.look_at(global_position + look_direction_3d)
		was_looking_somewhere = true
		%ShittyVisual.show()
		prev_direction = look_direction_3d
	%ShittyVisual.rotation.y = eumling_visuals.rotation.y

func _process(_delta: float) -> void:
	reload_progress.value = 1 - attack_cooldown.time_left / attack_cooldown.wait_time

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("test")):
		spawn_bullet()
		# add_upgrade(Upgrade.new(Enum.UPGRADE.MOVEMENT_SPEED, Enum.UPGRADE_METHOD.MULTIPLIER, 2))

func spawn_bullet():
	spawner.spawn(self, eumling_visuals)

func check_upgrades_affecting_player(upgrade: Upgrade):
	match upgrade.type:
		Enum.UPGRADE.HEALTH:
			var new_max_health = get_value(Enum.UPGRADE.HEALTH)
			var heal_amount = new_max_health - max_health
			max_health = new_max_health
			if (heal_amount > 0): health += heal_amount
		Enum.UPGRADE.MOVEMENT_SPEED:
			speed = get_value(Enum.UPGRADE.MOVEMENT_SPEED)
		Enum.UPGRADE.SIZE:
			var new_size = get_value(Enum.UPGRADE.SIZE)
			eumling_visuals.scale = Vector3.ONE * new_size
			hurtbox_collision.shape.radius = hurtbox_start_sizes.x * new_size
			hurtbox_collision.shape.height = hurtbox_start_sizes.y * new_size
		Enum.UPGRADE.PROJECTILE_AMOUNT:
			attack_spawner.amount_of_spawns = int(get_value(Enum.UPGRADE.PROJECTILE_AMOUNT))
		Enum.UPGRADE.RANGE:
			update_attack_visual()
		Enum.UPGRADE.PROJECTILE_SIZE:
			update_attack_visual()

func update_attack_visual():
	var projectile_default_size = 0.25
	%ShittyVisual.get_child(0).mesh.size.x = get_value(Enum.UPGRADE.PROJECTILE_SIZE) * projectile_default_size
	%ShittyVisual.get_child(0).mesh.size.y = get_value(Enum.UPGRADE.RANGE)
	%ShittyVisual.get_child(0).position.z = - get_value(Enum.UPGRADE.RANGE) / 2


func add_upgrade(upgrade: Upgrade):
	var value = _current_values.get_or_add(upgrade.type, 0)
	var new_value = upgrade.apply(value)
	if new_value < 0: return
	if min_max_values.has(upgrade.type):
		var limits: Vector2 = min_max_values.get(upgrade.type)
		new_value = clamp(new_value, limits.x, limits.y)
	_current_values.set(upgrade.type, new_value)
	upgrade_added.emit(upgrade)
	check_upgrades_affecting_player(upgrade)

func get_possible_upgrades() -> Array[Upgrade]:
	var upgrades: Array[Upgrade] = [] # weapon.get_possible_upgrades().duplicate()
	upgrades.append_array(possible_upgrades)
	return upgrades

func die():
	anim_player.set("parameters/DeathOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	hurtbox.process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer(2).timeout
	died.emit()

func revive():
	hurtbox.process_mode = Node.PROCESS_MODE_INHERIT
	anim_player.set("parameters/DeathOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)


func _get_configuration_warnings() -> PackedStringArray:
	var warning: String = ""
	if Enum.UPGRADE.keys().size() != starting_values.keys().size():
		warning += "Not all starting values are set, the following are missing:\n"
		for key in Enum.UPGRADE.values():
			if not starting_values.has(key):
				warning += Enum.UPGRADE.keys()[key] + ", "
		warning += "\nUnset values are defaulted to 0."

	if warning != "":
		return [warning]
	return []

func shoot():
	if not attack_cooldown.is_stopped(): return
	anim_player.set("parameters/Shoot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	var cooldown = get_value(Enum.UPGRADE.ATTACK_COOLDOWN)
	attack_cooldown.start(cooldown)
	attack_spawner.spawn(self, eumling_visuals)
	%ShittyVisual.get_child(0).material_override.albedo_color = Color(1, 0, 0, 17.0 / 255)


func reset_preview_color():
	%ShittyVisual.get_child(0).material_override.albedo_color = initial_preview_color


func end_of_level():
	var amount_to_regenerate = get_value(Enum.UPGRADE.HEALTH_REGENERATION)
	health += amount_to_regenerate
