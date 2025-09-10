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

var overlapping: Array = []

func _on_area_entered(area: Area3D) -> void:
	if (area is HurtBox):
		if (overlapping.find(func (_obj): return _obj.area == area) < 0):
			overlapping.append({area = area, counter = 1, cooldown = -1.0})

func _on_area_exited(area: Area3D) -> void:
	if (area is HurtBox):
		var index = overlapping.find_custom(func (_obj): return _obj.area == area)
		overlapping.remove_at(index)


func _physics_process(delta: float) -> void:
	for obj in overlapping:
		if (individual_hit_limit > 0 && obj.counter >= individual_hit_limit):
			continue
		obj.cooldown -= delta
		if (obj.cooldown <= 0):
			hit.emit(obj.area)
			obj.area.hurt(self)
			obj.counter += 1
			obj.cooldown = damage_cooldown
