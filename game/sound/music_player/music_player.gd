class_name MusicPlayer extends AudioStreamPlayer



#TODO: 



@export var ambientNoisePlayer:AudioStreamPlayer
var current_track:String
var current_env:String
enum LEVEL {
MENU, 
COMBAT_ISLAND, 
BOSS_GENERIC,
BOSS_ISLAND, 
CHASE
}
@export var debug:bool
@onready var debug_ui = $DebugUI


@onready var init_bus_volume = AudioServer.get_bus_volume_db(1)

func _ready():
	
	if debug:
		debug_list_setup()
		debug_ui.visible = true
	print(ambientNoisePlayer)

func debug_list_setup():
	var selector:ItemList = debug_ui.get_child(0)
	for type in LEVEL.values():
		selector.add_item(LEVEL.keys()[type])
	

func start_playback(names:Array[String]):
	var track_name = names[0]
	var env_name = names[1]
	if playing == false:
		play()
		
	if track_name != current_track:
		get_stream_playback().switch_to_clip_by_name(track_name)
	if env_name != current_env:
		if env_name == "":
			ambientNoisePlayer.stop()
		else:
			ambientNoisePlayer.play()
			ambientNoisePlayer.get_stream_playback().switch_to_clip_by_name(env_name)
			print(ambientNoisePlayer.get_stream_playback().get_current_clip_index())
	
	#print("clipIndex = ", get_stream_playback().get_current_clip_index())
	update_track_tail_volume()
	current_track = track_name
	current_env = env_name
func queue_random_track():
	var next_track = random_track()
	start_playback(next_track)
	
func queue_specific_track(level_type:LEVEL):
	var next_track = select_track(level_type) 
	start_playback(next_track)

func select_track(level_type:LEVEL) -> Array[String]:
	#print(level_type)
	var selected_track = "Menu"
	var selected_ambient = ""
	match level_type:
		
		
		LEVEL.MENU:
			selected_track = "Menu"
		LEVEL.COMBAT_ISLAND:
			selected_track = "CombatIsland"
			selected_ambient = "Island"
		LEVEL.BOSS_GENERIC:
			selected_track = "BossGeneric"
		LEVEL.BOSS_ISLAND:
			selected_track = "BossIsland"
			selected_ambient = "Island"
		LEVEL.CHASE:
			selected_track = "Chase"

	
	
	return [(selected_track+" Intro"),selected_ambient]
	
func random_track() -> Array[String]:
	return select_track(LEVEL.values().pick_random())

func update_track_tail_volume():
	
	#lower tail volume of previous track
	var current_stream_synchronised = get_current_stream_synchronised()
	if current_stream_synchronised is AudioStreamSynchronized: 
		current_stream_synchronised.set_sync_stream_volume(1,-60.0)
	
	
	await get_tree().create_timer(60).timeout
	
	current_stream_synchronised = get_current_stream_synchronised()

	current_stream_synchronised.set_sync_stream_volume(1,0.0)
	#print(current_stream_synchronised.get_sync_stream_volume(1))
	#implement reset

func get_current_stream_synchronised():
	return  stream.get_clip_stream(get_stream_playback().get_current_clip_index())



func fade_volume(out:bool , duration:float, reduction_db:float = 20):
	#print("bus"+ AudioServer.get_bus_name(1))
	#print(AudioServer.get_bus_volume_db(1))
	var tween = get_tree().create_tween()
	if out:
		tween.tween_method(func(v): AudioServer.set_bus_volume_db(1, v),init_bus_volume,-reduction_db,duration)
		tween.tween_method(func(v): AudioServer.set_bus_volume_db(2, v),init_bus_volume,-reduction_db,duration)
		#print("out")
	else:
		tween.tween_method(func(v): AudioServer.set_bus_volume_db(1, v),AudioServer.get_bus_volume_db(1),init_bus_volume,duration)
		tween.tween_method(func(v): AudioServer.set_bus_volume_db(2, v),AudioServer.get_bus_volume_db(1),init_bus_volume,duration)
		#print("in")
	#print(AudioServer.get_bus_volume_db(1))



func _on_debug_list_item_clicked(index, _at_position, _mouse_button_index):
	for key in LEVEL.values():
		#print(key)
		if key == index:
			queue_specific_track(key)


func _on_game_request_music(random:bool = false, level_type:LEVEL = LEVEL.MENU):
	
	if random:
		queue_random_track()
	else:
		queue_specific_track(level_type)


func _on_fade_in_button_pressed() -> void:
	fade_volume(false, 1)



func _on_fade_out_button_pressed() -> void:
	fade_volume(true, 1)
