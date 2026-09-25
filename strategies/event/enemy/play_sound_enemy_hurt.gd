@icon("res://strategies/strategy.svg")
@tool
extends PlaySoundEventStrategy
class_name PlaySoundEnemyHurtEventStrategy


@export var sound_to_play_on_crit:Array[String] =[]


func execute_event(_data):
	if _data is HitBox:
		if _data.get_damage_info().critical:
			sound_manager.play_sound(sound_to_play_on_crit, false, needs_to_be_persistent)
			print("played crit")
		else:
			sound_manager.play_sound(sound_to_play, false, needs_to_be_persistent)
			print("played normal")
