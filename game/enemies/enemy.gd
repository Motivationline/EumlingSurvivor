extends StateMachinePoweredEntity
class_name Enemy

@export_category("Base Values")

## How much (max)health this entity has. May be modified by upgrades.
@export var health: float:
	set(new_value):
		health = new_value
		if (max_health > 0):
			health = clampf(new_value, 0, max_health)
		if (healthbar): healthbar.health = health
		if (health <= 0 && !cannot_die):
			_die()
		# TODO: add damage number popup
## How fast this entity moves when it moves
@export_range(0, 100, 0.1) var speed: float = 1

@export_category("Base Functionality")
## ignores enemy when for level finish
@export var ignore_enemy_in_level: bool = false
@export var healthbar: Healthbar3D
@export var hitbox: HitBox
@export var hurtbox: HurtBox

@export_category("Event Listeners")
@export var on_death: Array[EventStrategy]
@export var on_hit: Array[EventStrategy]
@export var on_hurt: Array[EventStrategy]

@export_category("Debug Stuff")
@export var cannot_die: bool = false
@export var heal_back_to_full: bool = false


@onready var visuals: Node3D = $Visuals

var max_health: float
var reset_timer: Timer

var animation_tree: AnimationTree

func _ready() -> void:
	super()
	max_health = health
	if (healthbar): healthbar.init_health(max_health)
	if (hitbox): hitbox.hit.connect(_hit)
	if (hurtbox): hurtbox.hurt_by.connect(_hurt_by)

	animation_tree = Utils.find_first_animation_tree(node_with_animation_tree if (node_with_animation_tree) else self)

	Strategy._setup_array(on_death, self, self)
	Strategy._setup_array(on_hit, self, self)
	Strategy._setup_array(on_hurt, self, self)
	
	if !ignore_enemy_in_level:
		add_to_group("Enemy")

	reset_timer = Timer.new()
	add_child(reset_timer)
	reset_timer.timeout.connect(reset_health)


func _hit(_attackee: HurtBox):
	for ev in on_hit:
		ev.event_triggered(_attackee)

func _hurt_by(_attacker: HitBox):
	health -= _attacker.damage
	for ev in on_hurt:
		ev.event_triggered(_attacker)
	if (heal_back_to_full): reset_timer.start(3)

func _die():
	for ev in on_death:
		ev.event_triggered(null)
	queue_free()


func reset_health():
	if (heal_back_to_full):
		health = max_health
