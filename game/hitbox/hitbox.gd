@tool
extends Area3D
## HitBox is used to detect hits, lol. [br]
## [member hit] signal to detect hits
class_name HitBox

## How much damage should this hitbox deal. Might be modified by the parent of the hitbox, e.g. a projectile.
@export var damage: float = 0.0:
	get():
		if critical_hit_chance > randf():
			# critical hit
			return damage * critical_hit_damage_multiplier
		return damage

## How often this hitbox can hit a specific hurtbox. 0 or less = no limit 
@export var individual_hit_limit: int = 0

## How long between individual damage applications to a specific hurtbox
@export var damage_cooldown: float = 0.5

## signal that is emitted when hit
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

@export_category("Critical Hits")

## How likely is the critical hit to occur? May get overwritten by parent.
@export_range(0.0, 1.0, 0.01) var critical_hit_chance: float = 0.0

## How much should the damage be multiplied by? May get overwritten by parent.
@export var critical_hit_damage_multiplier: float = 2.0

@export_category("i-frames Overrides")
## Can still hurt the entity even if it has active iframes
@export var ignores_iframes: bool = false 
## Causes iframes on the entity to trigger
@export var causes_iframes: bool = true 

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if (attached_to == Enum.HITBOX.NONE):
		warnings.push_back("Attached To must be set to either Player or Enemy.")
	if (can_hit == Enum.HURTBOX.NONE):
		warnings.push_back("Can Hit must be set to either Player or Enemy.")
	if ((attached_to == Enum.HITBOX.PLAYER && can_hit == Enum.HURTBOX.PLAYER) || (attached_to == Enum.HITBOX.ENEMY && can_hit == Enum.HURTBOX.ENEMY)):
		warnings.push_back("Attached To and Can Hit probably shouldn't have the same value.")
	
	return warnings

var overlapping: Array = []

func _on_area_entered(area: Area3D) -> void:
	if (Engine.is_editor_hint()): return
	if (area is HurtBox):
		if (overlapping.find(func (_obj): return _obj.area == area) < 0):
			overlapping.append({area = area, counter = 0, cooldown = -1.0})

func _on_area_exited(area: Area3D) -> void:
	if (Engine.is_editor_hint()): return
	if (area is HurtBox):
		var index = overlapping.find_custom(func (_obj): return _obj.area == area)
		overlapping.remove_at(index)


func _physics_process(delta: float) -> void:
	if (Engine.is_editor_hint()): return
	for obj in overlapping:
		if (individual_hit_limit > 0 && obj.counter >= individual_hit_limit):
			continue
		obj.cooldown -= delta
		if (obj.cooldown <= 0):
			hit.emit(obj.area)
			obj.area.hurt(self)
			obj.counter += 1
			obj.cooldown = damage_cooldown
