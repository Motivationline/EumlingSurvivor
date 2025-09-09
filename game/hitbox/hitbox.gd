@tool
extends Area3D
class_name HitBox

## How much damage should this hitbox deal. Might be modified by the parent of the hitbox, e.g. a projectile.
@export var damage: float = 0.0

## How often this hitbox can hit a specific hurtbox. 0 or less = no limit 
@export var individual_hit_limit: int = 0

## How long between individual damage applications to a specific hurtbox
@export var damage_cooldown: float = 0.5

signal hit(hurtbox: HurtBox)

@export var attached_to: Enum.HITBOX = Enum.HITBOX.NONE:
	set(_hitbox):
		if (attached_to > 0): set_collision_layer_value(attached_to, false)
		attached_to = _hitbox
		if (attached_to > 0): set_collision_layer_value(attached_to, true)
		update_configuration_warnings()

@export var can_hit: Enum.HURTBOX = Enum.HURTBOX.NONE:
	set(_hurtbox):
		if (can_hit > 0): set_collision_mask_value(can_hit, false)
		can_hit = _hurtbox
		if (can_hit > 0): set_collision_mask_value(can_hit, true)
		update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if (attached_to == Enum.HITBOX.NONE):
		warnings.push_back("Attached To must be set to either Player or Enemy.")
	if (can_hit == Enum.HURTBOX.NONE):
		warnings.push_back("Can Hit must be set to either Player or Enemy.")
	if ((attached_to == Enum.HITBOX.PLAYER && can_hit == Enum.HURTBOX.PLAYER) || (attached_to == Enum.HITBOX.ENEMY && can_hit == Enum.HURTBOX.ENEMY)):
		warnings.push_back("Attached To and Can Hit probably shouldn't have the same value.")
	
	return warnings

var hurt_counter_tracker: Dictionary[HurtBox, int] = {}
var hurt_cooldown_tracker: Dictionary[HurtBox, float] = {}
var overlapping: Array[HurtBox]

func _on_area_entered(area: Area3D) -> void:
	if (area is HurtBox):
		if (!hurt_cooldown_tracker.has(area)):
			hurt_cooldown_tracker.set(area, -1)
		if (!hurt_counter_tracker.has(area)):
			hurt_counter_tracker.set(area, 0)

func _on_area_exited(area: Area3D) -> void:
	if (area is HurtBox):
		if (hurt_cooldown_tracker.has(area)):
			hurt_cooldown_tracker.erase(area)

func _physics_process(delta: float) -> void:
	for area in hurt_cooldown_tracker:
		if (individual_hit_limit > 0 && hurt_counter_tracker.get(area) >= individual_hit_limit):
			continue
		var current_cooldown = hurt_cooldown_tracker.get(area)
		current_cooldown -= delta
		if (current_cooldown <= 0):
			hit.emit(area)
			area.hurt(self)
			current_cooldown = damage_cooldown
		hurt_cooldown_tracker.set(area, current_cooldown)
	pass
