extends StateMachinePoweredEntity

var health: float = 0:
	set(value):
		health = clampf(value, 0, _max_health)
		if health == 0 and not broken: break_again()
		if status_visuals:
			status_visuals.health = health
var _max_health: float = 200
@export var max_health: Array[float] = [100]
var _repair_per_second: float = 25
@export var repair_per_second: Array[float] = [25]

@export_group("Functionality Stuff")
@export var repair_area: Area3D
@export var repaired_state: State
@export var broken_state: State
@export var level_completed_state: State
@export var status_visuals: StatusVisualsPlayer
@export var sound_player: SoundEffectManager

@onready var visuals: Node3D = $Visuals
@export var hurtbox: HurtBox


var player_present: bool = false
var broken: bool = true

var _level: int = 0

func _ready() -> void:
	visuals.rotation = rotation
	rotation = Vector3.ZERO

	_level = Data._active_mini_eumlings.count(Enum.EUMLING_TYPE.REALISTIC)
	if _level <= 0:
		queue_free()
		return
	repair_area.body_entered.connect(entity_entered)
	repair_area.body_exited.connect(entity_exited)

	var health_index: int = clampi(_level - 1, 0, max_health.size() - 1)
	_max_health = max_health[health_index]
	status_visuals.max_health = _max_health
	status_visuals.health = 0
	var repair_index: int = clampi(_level - 1, 0, repair_per_second.size() - 1)
	_repair_per_second = repair_per_second[repair_index]
	
	if (hurtbox): hurtbox.hurt_by.connect(_hurt_by)

	super()

func entity_entered(body: CharacterBody3D):
	if body == Player.player:
		player_present = true
		sound_player.play_sound("RepairLoop")
func entity_exited(body: CharacterBody3D):
	if body == Player.player:
		player_present = false
		sound_player.stop_sound("RepairLoop")

func _process(_delta: float):
	super(_delta)
	if player_present:
		health += _repair_per_second * _delta
	if broken:
		if health == _max_health:
			repair()
	

func repair():
	broken = false
	sound_player.stop_sound("RepairLoop")
	state_machine.switch_to_state(repaired_state)
	$Visuals.find_child("DriverSeat").show()
	status_visuals.show_health_numbers = true
	hurtbox.monitorable = true
	hurtbox.monitoring = true
	
	var level: Level = get_tree().get_first_node_in_group("Level")
	if level.cleared:
		repaired_state.exited.connect(level_cleared)
	else:
		level.level_cleared.connect(level_cleared)
	
	# remove R mini eumlings
	var minis = get_tree().get_nodes_in_group("MiniEumling")
	for m in minis:
		if m.name == "MiniEumlingR":
			m.queue_free()

func break_again():
	broken = true
	status_visuals.show_health_numbers = false
	state_machine.switch_to_state(broken_state)
	hurtbox.monitorable = false
	hurtbox.monitoring = false
	
	var level: Level = get_tree().get_first_node_in_group("Level")
	level.level_cleared.disconnect(level_cleared)

func level_cleared():
	await get_tree().process_frame
	state_machine.switch_to_state(level_completed_state)

func _hurt_by(area: HitBox):
	health -= area.damage
	Utils.create_damage_number(self , "%d" % area.damage)
