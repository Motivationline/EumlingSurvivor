extends CharacterBody3D
class_name Player

@export var base_speed: float = 5.0
var speed: float
@export var base_health: float = 10.0
var health: float = 10.0:
	set(new_value):
		if (max_health <= 0):
			health = new_value
		else:
			health = clampf(new_value, 0, max_health)
		if (healthbar):
			healthbar.health = health
var max_health: float:
	set(value):
		max_health = value
		if (healthbar):
			healthbar.max_health = max_health

@export var weapon: Weapon

@export_category("")
@export var eumling_visuals: Node3D
@export var spawner: EntitySpawner

@onready var healthbar: Healthbar = $CanvasLayer/Control/Healthbar
@onready var hurtbox: HurtBox = $Hurtbox

var active_upgrades: Dictionary[Enum.UPGRADE, Array] = {}
signal upgrade_added

var possible_upgrades: Array[Upgrade] = [
	Upgrade.new(Enum.UPGRADE.HEALTH, Enum.UPGRADE_METHOD.MULTIPLIER, 1.1),
	Upgrade.new(Enum.UPGRADE.MOVEMENT_SPEED, Enum.UPGRADE_METHOD.MULTIPLIER, 1.25),
]

func _ready() -> void:
	add_to_group("Player")
	max_health = base_health
	health = base_health
	speed = base_speed

	if (healthbar): healthbar.init_health(max_health)
	if (hurtbox): hurtbox.hurt_by.connect(hurt_by)
	if (weapon): weapon.setup(self)

func hurt_by(_area: HitBox):
	health -= _area.damage
	# TODO: add invulnerability?

	# TODO: re-enable this if we want more hit impact
	# if (_area.damage > 0):
	# 	Engine.time_scale = 0.1
	# 	await get_tree().create_timer(0.1, true, true, true).timeout
	# 	Engine.time_scale = 1

func _physics_process(_delta: float) -> void:
	var direction = Input.get_vector("left", "right", "up", "down")
	var direction_3d = Vector3(direction.x, 0, direction.y)
	velocity = direction_3d * speed
	move_and_slide()
	
	if (!direction.is_zero_approx()):
		eumling_visuals.look_at(global_position + direction_3d)
	
	if (weapon): weapon.physics_process(_delta)

func _process(delta: float) -> void:
	if (weapon): weapon.process(delta)

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("test")):
		# spawn_bullet()
		add_upgrade(Upgrade.new(Enum.UPGRADE.MOVEMENT_SPEED, Enum.UPGRADE_METHOD.MULTIPLIER, 2))

func spawn_bullet():
	spawner.spawn(self, eumling_visuals)

func check_upgrades_affecting_player(upgrade: Upgrade):
	match upgrade.type:
		Enum.UPGRADE.HEALTH:
			var new_max_health = Upgrade.apply_all(base_health, get_upgrades_for(Enum.UPGRADE.HEALTH))
			var heal_amount = new_max_health - max_health
			max_health = new_max_health
			if (heal_amount > 0): health += heal_amount
		Enum.UPGRADE.MOVEMENT_SPEED:
			speed = Upgrade.apply_all(base_speed, get_upgrades_for(Enum.UPGRADE.MOVEMENT_SPEED))

func add_upgrade(upgrade: Upgrade):
	var upgrades = get_upgrades_for(upgrade.type)
	upgrades.append(upgrade)
	active_upgrades.set(upgrade.type, upgrades)
	upgrade_added.emit(upgrade)
	check_upgrades_affecting_player(upgrade)

func get_upgrades_for(type: Enum.UPGRADE) -> Array[Upgrade]:
	if (!active_upgrades.has(type)): return []
	return active_upgrades.get(type)

func get_possible_upgrades() -> Array[Upgrade]:
	var upgrades = weapon.get_possible_upgrades().duplicate()
	upgrades.append_array(possible_upgrades)
	return upgrades
