@tool
extends Area3D
class_name HitBox

var damage: float

# TODO damage tick rate

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


func _on_area_entered(area: Area3D) -> void:
	if (area is HurtBox):
		hit.emit(area)
