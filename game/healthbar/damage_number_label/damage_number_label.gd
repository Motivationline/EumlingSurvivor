class_name DamageNumberLabel
extends Node3D

## How far from the center of the entity can the damage number be offset
@export var max_offset: float = 0.2

@export_category("Label Styles")
@export var player_style: DamageNumberStyle
@export var healing_style: DamageNumberStyle
@export var enemy_style: DamageNumberStyle
@export var reduced_style: DamageNumberStyle
@export var increased_style: DamageNumberStyle
@export var multiple_increased_style: DamageNumberStyle

@onready var label := $DamageNumberLabel as Label3D


func setup(damage_info: DamageInfo, entity_position: Vector3) -> void:
	if not label:
		push_error("Could not find a Label3D. Make sure the setup function is called after the node is added to the scene tree.")
		return

	var damage_increases: int = damage_info.damage_increase_count()

	var label_style := get_label_style(damage_info, damage_increases == 1, damage_increases > 1)

	label.modulate = label_style.color
	label.text = str(roundi(abs(damage_info.amount))) + label_style.suffix
	scale = Vector3.ONE * label_style.scale
	global_position = entity_position + random_offset()


func get_label_style(damage_info: DamageInfo, single_increased: bool, multiple_increased: bool) -> DamageNumberStyle:	
	if damage_info.is_healing():
		return healing_style
	
	if damage_info.is_reduced():
		var label_style := reduced_style.copy()
		if single_increased:
			label_style.scale *= increased_style.scale
			label_style.suffix = increased_style.suffix
		elif multiple_increased:
			label_style.scale *= multiple_increased_style.scale
			label_style.suffix = multiple_increased_style.suffix
		return label_style
	
	if single_increased:
		return increased_style
	elif multiple_increased:
		return multiple_increased_style
	
	if damage_info.entity_type == Enum.HITBOX.ENEMY:
		return enemy_style
	
	return player_style


func random_offset() -> Vector3:
	return Vector3(
			randf_range(-max_offset, max_offset),
			0.0,
			randf_range(-max_offset, max_offset))
