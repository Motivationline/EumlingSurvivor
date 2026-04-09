extends StateMachinePoweredEntity
class_name Enemy

@export_category("Base Values")

## How much (max)health this entity has. May be modified by upgrades.
@export var health: float:
	set(new_value):
		health = new_value
		if (max_health > 0):
			health = clampf(new_value, 0, max_health)
		if (status_visuals): status_visuals.health = health
		if (health <= 0 && !cannot_die):
			_die()
		# TODO: add damage number popup

## multiplies any incoming damage with this value.
## e.g. a value of 0.5 means you only take half the damage you normally would.
## 1.0 means no change.
@export var incoming_damage_multiplier: float = 1.0

## How fast this entity moves when it moves
@export_range(0, 100, 0.1) var speed: float = 1

@export_category("Death")
@export var death_effect: PackedScene

@export_category("Difficulty Overrides")
@export var difficulty_scaler: DifficultyScaler

@export_category("Base Functionality")
## ignores enemy when for level finish
@export var ignore_enemy_in_level: bool = false
@export var status_visuals: StatusVisualsEnemy
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
@onready var vulnerability_display: VulnerabilityDisplay = $VulnerabilityDisplay

const DAMAGE_NUMBER_LABEL = preload("uid://dm4mgjmi078lm")

var max_health: float:
	set(value):
		if value != max_health and status_visuals:
			status_visuals.max_health = value
		max_health = value
var reset_timer: Timer
var convince_progress: float = 0

var animation_tree: AnimationTree

func _ready() -> void:
	if difficulty_scaler:
		difficulty_scaler.setup_and_apply(self, owner)
	super ()
	max_health = health
	if (status_visuals): status_visuals.init_health(max_health)
	if (hitbox): hitbox.hit.connect(_hit)
	if (hurtbox): hurtbox.hurt_by.connect(_hurt_by)

	animation_tree = Utils.find_first_animation_tree(node_with_animation_tree if (node_with_animation_tree) else self )

	Strategy._setup_array(on_death, self , self )
	Strategy._setup_array(on_hit, self , self )
	Strategy._setup_array(on_hurt, self , self )
	
	if !ignore_enemy_in_level:
		add_to_group("Enemy")

	reset_timer = Timer.new()
	add_child(reset_timer)
	reset_timer.timeout.connect(reset_health)


func _hit(_attackee: HurtBox):
	for ev in on_hit:
		ev.event_triggered(_attackee)

func _hurt_by(_attacker: HitBox):
	if _attacker is SocialAOEHitBox:
		convince_progress += _attacker.rate
		status_visuals.social_progress = convince_progress / max_health
		if convince_progress > max_health:
			health = 0
		return
	var projectile = _attacker.get_parent()
	var damage = _attacker.damage
	var hit_vulnerability: bool = false
	if projectile is Projectile:
		hit_vulnerability = vulnerability_display.try_to_hit(projectile)
		if hit_vulnerability:
			damage *= Player.player.get_ability(Enum.EUMLING_TYPE.INVESTIGATIVE).multiplier
	damage *= incoming_damage_multiplier

	health -= damage
	for ev in on_hurt:
		ev.event_triggered(_attacker)
	if (heal_back_to_full): reset_timer.start(3)
	if damage > 0:
		convince_progress = 0
		status_visuals.social_progress = 0

		var dmgText = "%d" % damage
		if hit_vulnerability: dmgText += "!"
		Utils.create_damage_number(self, dmgText)
		
func _die():
	for ev in on_death:
		ev.event_triggered(null)
	if not ignore_enemy_in_level:
		var effect = death_effect.instantiate()
		get_parent().add_child(effect)
		effect.global_position = global_position
	queue_free()


func reset_health():
	if (heal_back_to_full):
		health = max_health
