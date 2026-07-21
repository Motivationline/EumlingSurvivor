class_name DamageInfo
extends RefCounted

var amount: float
var entity_type := Enum.HITBOX.NONE
var multiplier: float = 1.0
var critical: bool = false
var vulnerability: bool = false


func _init(damage: float) -> void:
	amount = damage


func damage_increase_count() -> int:
	var damage_increases: int = 0
	if multiplier > 1.0:
		damage_increases += 1
	if critical:
		damage_increases += 1
	if vulnerability:
		damage_increases += 1
	return damage_increases


func is_reduced() -> bool:
	return multiplier < 1.0


func is_healing() -> bool:
	return amount < 0.0
