extends CharacterBody3D
class_name Player

@export var speed := 5.0
const BULLET = preload("res://game/projectiles/example_bullet/example_bullet.tscn")
@export var spawner: EntitySpawner
@export var eumling_visuals: Node3D

var active_upgrades: Dictionary[Enum.UPGRADE, Array] = {}
signal upgrade_added

func _ready() -> void:
	add_to_group("Player")

func _physics_process(_delta: float) -> void:
	var direction = Input.get_vector("left", "right", "up", "down")
	var direction_3d = Vector3(direction.x, 0, direction.y)
	velocity = direction_3d * speed
	move_and_slide()

	
	if (!direction.is_zero_approx()):
		eumling_visuals.look_at(global_position + direction_3d)

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("test")):
		spawn_bullet()

func spawn_bullet():
	# var instance = BULLET.instantiate()
	# get_parent().add_child(instance)
	# instance.setup(Enum.GROUP.PLAYER, global_position, global_rotation, global_position + basis.z * -5)
	spawner.spawn(self, eumling_visuals)

func add_upgrade(upgrade: UpgradeStrategy):
	var upgrades = get_upgrades_for(upgrade.type)
	upgrades.append(upgrade)
	active_upgrades.set(upgrade.type, upgrades)
	upgrade_added.emit(upgrade)

func get_upgrades_for(type: Enum.UPGRADE) -> Array[UpgradeStrategy]:
	if (!active_upgrades.has(type)): return []
	return active_upgrades.get(type)
