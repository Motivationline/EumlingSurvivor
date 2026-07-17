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
@export var additional_hurtboxes: Array[HurtBox]
@export var additional_hitboxes: Array[HitBox]

@export_category("Event Listeners")
@export var on_death: Array[EventStrategy]
@export var on_hit: Array[EventStrategy]
@export var on_hurt: Array[EventStrategy]

@export_category("Debug Stuff")
@export var cannot_die: bool = false
@export var heal_back_to_full: bool = false


@onready var visuals: Node3D = $Visuals
@onready var vulnerability_display: VulnerabilityDisplay = $VulnerabilityDisplay

signal died
signal hurt

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
	
	fix_visuals_and_root_rotation()
	max_health = health
	if (status_visuals): status_visuals.init_health(max_health)
	if (hitbox): hitbox.hit.connect(_hit)
	for box in additional_hitboxes:
		box.hit.connect(_hit)
	if (hurtbox): hurtbox.hurt_by.connect(_hurt_by)
	for box in additional_hurtboxes:
		box.hurt_by.connect(_hurt_by)

	animation_tree = Utils.find_first_animation_tree(node_with_animation_tree if (node_with_animation_tree) else self )

	Strategy._setup_array(on_death, self , self )
	Strategy._setup_array(on_hit, self , self )
	Strategy._setup_array(on_hurt, self , self )
	
	if !ignore_enemy_in_level:
		add_to_group("Enemy")

	reset_timer = Timer.new()
	add_child(reset_timer)
	reset_timer.timeout.connect(reset_health)

func fix_visuals_and_root_rotation():
	visuals.rotation = rotation
	rotation = Vector3(0,0,0)


func _hit(_attackee: HurtBox):
	_trigger_events(on_hit, _attackee)

func _hurt_by(_attacker: HitBox):
	if _attacker is SocialAOEHitBox:
		if ignore_enemy_in_level: return
		convince_progress += _attacker.rate
		status_visuals.social_progress = convince_progress / max_health
		if convince_progress > max_health:
			health = 0
		return
	var projectile = _attacker.get_parent()
	var damage_info := _attacker.get_damage_info()
	damage_info.entity_type = Enum.HITBOX.ENEMY
	var hit_vulnerability: bool = false
	if projectile is Projectile:
		hit_vulnerability = vulnerability_display.try_to_hit(projectile)
		if hit_vulnerability:
			damage_info.amount *= Player.player.get_ability(Enum.EUMLING_TYPE.INVESTIGATIVE).multiplier
	damage_info.amount *= incoming_damage_multiplier

	if damage_info.amount > 0:
		hurt.emit()
	health -= damage_info.amount
	_trigger_events(on_hurt, _attacker)
	if (heal_back_to_full): reset_timer.start(3)
	if damage_info.amount > 0:
		convince_progress = 0
		status_visuals.social_progress = 0

		damage_info.vulnerability = hit_vulnerability
		damage_info.multiplier = incoming_damage_multiplier
		Utils.create_damage_number_label(self, damage_info)
	if projectile is Projectile and projectile.shooter == Player.player:
		Player.player.hit.emit(self)

func _die():
	died.emit()
	_trigger_events(on_death)
	if not ignore_enemy_in_level:
		var effect = death_effect.instantiate()
		effect.position = global_position
		effect.position.y = 0.0
		get_parent().add_child(effect)
	queue_free()


func reset_health():
	if (heal_back_to_full):
		health = max_health

func _trigger_events(arr: Array[EventStrategy], value: Variant = null):
	for ev in arr:
		if ev:
			ev.event_triggered(value)
		else:
			push_warning("%s tried to trigger a null event. Fix your references!" % [self.name])
