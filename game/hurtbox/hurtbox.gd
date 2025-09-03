@tool
extends Area3D
class_name HurtBox

enum HITBOX {NONE = 0, PLAYER = 3, ENEMY = 6}
enum HURTBOX {NONE = 0, PLAYER = 4, ENEMY = 7}

signal hurt_by(hitbox: HitBox)

@export var attached_to: HURTBOX = HURTBOX.NONE:
	set(_hitbox):
		if (attached_to > 0): set_collision_mask_value(attached_to, false)
		attached_to = _hitbox
		if (attached_to > 0): set_collision_mask_value(attached_to, true)
		update_configuration_warnings()

@export var can_be_hit_by: HITBOX = HITBOX.NONE:
	set(_hurtbox):
		if (can_be_hit_by > 0): set_collision_layer_value(can_be_hit_by, false)
		can_be_hit_by = _hurtbox
		if (can_be_hit_by > 0): set_collision_layer_value(can_be_hit_by, true)
		update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if (attached_to == HURTBOX.NONE):
		warnings.push_back("Attached To must be set to either Player or Enemy.")
	if (can_be_hit_by == HITBOX.NONE):
		warnings.push_back("Can Be Hit By must be set to either Player or Enemy.")
	if ((attached_to == HURTBOX.PLAYER && can_be_hit_by == HITBOX.PLAYER) || (attached_to == HURTBOX.ENEMY && can_be_hit_by == HITBOX.ENEMY)):
		warnings.push_back("Attached To and Can Be Hit By probably shouldn't have the same value.")
	return warnings


func _on_area_entered(area: Area3D) -> void:
	if (area is HitBox):
		hurt_by.emit(area)
