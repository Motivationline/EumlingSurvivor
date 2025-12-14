class_name SoundEffectManager extends Node3D

var sound_list:Dictionary
@export var debug:bool
@export var debug_sound:String


@onready var debug_ui = $DebugUI
@onready var debug_list = $DebugUI/DebugSelector
@onready var music_player:MusicPlayer = get_tree().get_first_node_in_group("MusicPlayer")

func _ready() :
	sound_list_setup()
	if debug:
		debug_list_setup()

func _process(_delta):
	if debug:
		if Input.is_action_just_pressed("ui_end"):
			play_sound(debug_sound)
			
func sound_list_setup():
	for sound in get_children():
		if (sound is AudioStreamPlayer) or (sound is AudioStreamPlayer3D) or (sound is AudioStreamPlayer2D):
			sound_list[sound.name] = sound


func play_sound(sound_name:String, focus:bool = false, persistent = false):

	if sound_list.has(sound_name):
		var sound = sound_list[sound_name] 
		if persistent:
			sound.reparent(music_player)
			sound.finished.connect(sound.queue_free)

		sound.play()
		
		if focus:
			music_player.fade_in_and_out(sound.stream.get_length())
	else:
		print("Sound '"+sound_name+"' is missing!")
	

	
func debug_list_setup():
	debug_ui.show()
	debug_ui.focus_mode = 2
	debug_ui.call_deferred("grab_focus")
	for sound in sound_list.keys():
		#print(sound)
		debug_list.add_item(sound)



	
func _on_debug_list_item_clicked(index, _at_position, _mouse_button_index):
	var item_name = debug_list.get_item_text(index)
	play_sound(item_name)
	
	
