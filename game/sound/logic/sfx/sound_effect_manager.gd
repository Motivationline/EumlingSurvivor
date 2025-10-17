extends Node3D
class_name SoundEffectManager

var sound_list:Dictionary
@export var debug:bool


@onready var debug_ui = $DebugUI
@onready var debug_list = $DebugUI/DebugSelector


func _ready() :
	sound_list_setup()
	if debug:
		debug_list_setup()
	
func sound_list_setup():
	for sound in get_children():
		if sound is AudioStreamPlayer:
			sound_list[sound.name] = sound
	print(sound_list)

func playSound(index):
	sound_list[index].play()
	
func debug_list_setup():
	debug_ui.show()
	var selector:ItemList = debug_ui.get_child(0)
	for sound in sound_list:
		
		selector.add_item(sound)
	
func _on_debug_list_item_clicked(index, _at_position, _mouse_button_index):
	var item_name = debug_list.get_item_text(index)
	playSound(item_name)
