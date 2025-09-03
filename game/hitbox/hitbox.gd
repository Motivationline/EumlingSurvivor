@tool
extends Area3D
class_name HitBox

var damage: float

enum HITBOX {NONE = 0, PLAYER = 3, ENEMY = 6}
enum HURTBOX {NONE = 0, PLAYER = 4, ENEMY = 7}

signal hit(hurtbox: HurtBox)

@export var attached_to: HITBOX = HITBOX.NONE:
	set(_hitbox):
		if (attached_to > 0): set_collision_layer_value(attached_to, false)
		attached_to = _hitbox
		if (attached_to > 0): set_collision_layer_value(attached_to, true)
		update_configuration_warnings()

@export var can_hit: HURTBOX = HURTBOX.NONE:
	set(_hurtbox):
		if (can_hit > 0): set_collision_mask_value(can_hit, false)
		can_hit = _hurtbox
		if (can_hit > 0): set_collision_mask_value(can_hit, true)
		update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if (attached_to == HITBOX.NONE):
		warnings.push_back("Attached To must be set to either Player or Enemy.")
	if (can_hit == HURTBOX.NONE):
		warnings.push_back("Can Hit must be set to either Player or Enemy.")
	if ((attached_to == HITBOX.PLAYER && can_hit == HURTBOX.PLAYER) || (attached_to == HITBOX.ENEMY && can_hit == HURTBOX.ENEMY)):
		warnings.push_back("Attached To and Can Hit probably shouldn't have the same value.")
	
	return warnings


func _on_area_entered(area: Area3D) -> void:
	if (area is HurtBox):
		hit.emit(area)
