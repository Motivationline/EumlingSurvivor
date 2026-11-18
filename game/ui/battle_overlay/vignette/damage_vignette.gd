extends Control

@export_category("Animation Parameters")
@export var animation_speed:float = 1.0
@export var anim_player:AnimationPlayer



func on_damage() -> void:
	anim_player.play("damage", -1, animation_speed)
