@tool
extends Area3D
class_name HurtBox

# TODO: add invul frames?

signal hurt_by(hitbox: HitBox)

@export var attached_to: Enum.HURTBOX = Enum.HURTBOX.NONE:
	set(_hitbox):
		if (attached_to > 0): set_collision_layer_value(attached_to, false)
		attached_to = _hitbox
		if (attached_to > 0): set_collision_layer_value(attached_to, true)
		update_configuration_warnings()

@export var can_be_hit_by: Enum.HITBOX = Enum.HITBOX.NONE:
	set(_hurtbox):
		if (can_be_hit_by > 0): set_collision_mask_value(can_be_hit_by, false)
		can_be_hit_by = _hurtbox
		if (can_be_hit_by > 0): set_collision_mask_value(can_be_hit_by, true)
		update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if (attached_to == Enum.HURTBOX.NONE):
		warnings.push_back("Attached To must be set to either Player or Enemy.")
	if (can_be_hit_by == Enum.HITBOX.NONE):
		warnings.push_back("Can Be Hit By must be set to either Player or Enemy.")
	if ((attached_to == Enum.HURTBOX.PLAYER && can_be_hit_by == Enum.HITBOX.PLAYER) || (attached_to == Enum.HURTBOX.ENEMY && can_be_hit_by == Enum.HITBOX.ENEMY)):
		warnings.push_back("Attached To and Can Be Hit By probably shouldn't have the same value.")
	return warnings


func hurt(by: HitBox) -> void:
	hurt_by.emit(by)
