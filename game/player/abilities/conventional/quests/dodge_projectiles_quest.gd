class_name DodgeProjectilesQuest extends Quest

@export var dodge_amount_required: int = 3

@onready var dodge_area: Area3D = $DodgeArea
var dodged_projectiles: int = 0
var projectile_queue: Array = []
var current_time: float = 0
var queue_disabled: bool = false

func _ready() -> void:
	dodge_area.area_entered.connect(projectile_entered)

func start():
	Player.player.hurt.connect(player_hurt)
	dodged_projectiles = 0
	current_time = 0
	dodge_area.monitoring = true
	progress.emit(dodged_projectiles, dodge_amount_required)


func complete() -> void:
	super()
	Player.player.activate_shield()


func end():
	dodge_area.monitoring = false
	projectile_queue.clear()

func process(delta: float):
	current_time += delta
	while projectile_queue.size() > 0:
		var element = projectile_queue[0]
		if element[0] > current_time:
			break
		projectile_queue.pop_front()
		dodged_projectiles += 1
	progress.emit(dodged_projectiles, dodge_amount_required)
	if dodged_projectiles >= dodge_amount_required:
		complete()

func player_hurt():
	projectile_queue.clear()
	queue_disabled = true
	await get_tree().create_timer(Player.player.invulnerability_time, true).timeout
	queue_disabled = false

func projectile_entered(area: Area3D):
	if queue_disabled: return
	if not area.get_parent() is Projectile: return
	projectile_queue.append([current_time + 0.3, area])

func precondition_is_met() -> bool:
	return true
