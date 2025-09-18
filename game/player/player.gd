extends CharacterBody3D
class_name Player

@export var speed := 5.0
@export var eumling_visuals: Node3D
@export var spawner: EntitySpawner
@export var weapon: Weapon

var active_upgrades: Dictionary[Enum.UPGRADE, Array] = {}
signal upgrade_added

var possible_upgrades: Array[Upgrade] = [
	Upgrade.new(Enum.UPGRADE.HEALTH, Enum.UPGRADE_METHOD.MULTIPLIER, 1.1),
	Upgrade.new(Enum.UPGRADE.MOVEMENT_SPEED, Enum.UPGRADE_METHOD.MULTIPLIER, 1.25),
]

func _ready() -> void:
	add_to_group("Player")
	# weapon.player = self

func _physics_process(_delta: float) -> void:
	var direction = Input.get_vector("left", "right", "up", "down")
	var direction_3d = Vector3(direction.x, 0, direction.y)
	velocity = direction_3d * speed
	move_and_slide()
	
	if (!direction.is_zero_approx()):
		eumling_visuals.look_at(global_position + direction_3d)
	
	if (weapon): weapon.physics_process(_delta)

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("test")):
		spawn_bullet()

func spawn_bullet():
	spawner.spawn(self, eumling_visuals)

func add_upgrade(upgrade: Upgrade):
	var upgrades = get_upgrades_for(upgrade.type)
	upgrades.append(upgrade)
	active_upgrades.set(upgrade.type, upgrades)
	upgrade_added.emit(upgrade)

func get_upgrades_for(type: Enum.UPGRADE) -> Array[Upgrade]:
	if (!active_upgrades.has(type)): return []
	return active_upgrades.get(type)

func get_possible_upgrades() -> Array[Upgrade]:
	var upgrades = weapon.get_possible_upgrades()
	upgrades.append_array(possible_upgrades)
	return upgrades
