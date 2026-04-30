extends StateMachinePoweredEntity

var health: float = 0:
	set(value):
		health = clampf(value, 0, max_health)
		if health == 0 and not broken: break_again()
		if status_visuals:
			status_visuals.health = health
@export var max_health: float = 200
@export var repair_per_second: float = 40

@export_group("Functionality Stuff")
@export var repair_area: Area3D
@export var repaired_state: State
@export var broken_state: State
@export var level_completed_state: State
@export var status_visuals: StatusVisualsPlayer

@onready var visuals: Node3D = $Visuals
@export var hurtbox: HurtBox


var player_present: bool = false
var broken: bool = true

func _ready() -> void:
	if Data._active_mini_eumlings.count(Enum.EUMLING_TYPE.REALISTIC) <= 0:
		status_visuals.hide()
		return
	repair_area.body_entered.connect(entity_entered)
	repair_area.body_exited.connect(entity_exited)

	status_visuals.max_health = max_health
	status_visuals.health = 0
	
	if (hurtbox): hurtbox.hurt_by.connect(_hurt_by)

	super()

func entity_entered(body: CharacterBody3D):
	if body == Player.player:
		player_present = true
func entity_exited(body: CharacterBody3D):
	if body == Player.player:
		player_present = false

func _process(_delta: float):
	super(_delta)
	if player_present:
		health += repair_per_second * _delta
	if broken:
		if health == max_health:
			repair()
	

func repair():
	broken = false
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
