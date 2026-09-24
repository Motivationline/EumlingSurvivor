class_name DialogueSoundEffectManager extends SoundEffectManager


@export var sound_name:String
@export var sound_cooldown:int = 0
@export var dialogue_label:DialogueLabel



func _ready():
	super()
	dialogue_label.spoke.connect(on_spoken)
	

func on_spoken(_letter:String, _letter_index:int, _speed:float) -> void:
	if _letter_index % sound_cooldown == 0:
		play_sound(sound_name)
