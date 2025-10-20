extends AudioStreamPlayer



#TODO: 
#-check if current and next track are the same and continue playing,
#-implement level change stuff



enum level {
MENU, 
COMBAT, 
BOSS, 
CHASE, 
PARKOUR
}
@export var debug:bool
@onready var debug_ui = $DebugUI


@onready var init_bus_volume = AudioServer.get_bus_volume_db(1)

func _ready():
	
	if debug:
		debug_list_setup()
		debug_ui.visible = true
	

func debug_list_setup():
	var selector:ItemList = debug_ui.get_child(0)
	for type in level.values():
		selector.add_item(level.keys()[type])
	

func start_playback(track_name: String):
	if playing == false:
		play()
	get_stream_playback().switch_to_clip_by_name(track_name)
	print("clipIndex = ", get_stream_playback().get_current_clip_index())
	update_track_tail_volume()
	
func queue_random_track():
	var next_track = random_track()
	start_playback(next_track)
	
func queue_specific_track(level_type:level):
	var next_track = select_track(level_type) 
	start_playback(next_track)

func select_track(level_type:level) -> String:
	print(level_type)
	var selected_track
	match level_type:
		
		
		level.MENU:
			print("MENU playing")
			selected_track = "Menu"
		level.COMBAT:
			print("COMBAT playing")
			selected_track = "Combat"
		level.BOSS:
			print("BOSS playing")
			selected_track = "Boss"
		level.CHASE:
			print("CHASE playing")
			selected_track = "Chase"
		level.PARKOUR:
			print("PARKOUR playing")
			selected_track = "Parkour"
	
	
	return selected_track+" Intro"
	
func random_track() -> String:
	return select_track(level.values().pick_random())

func update_track_tail_volume():
	
	#lower tail volume of previous track
	var current_stream_synchronised = get_current_stream_synchronised()
	if current_stream_synchronised is AudioStreamSynchronized: 
		current_stream_synchronised.set_sync_stream_volume(1,-60.0)
	
	
	await get_tree().create_timer(60).timeout
	
	#raise tail volume of next track
	current_stream_synchronised = get_current_stream_synchronised()
	print(current_stream_synchronised.get_sync_stream_volume(1))
	current_stream_synchronised.set_sync_stream_volume(1,0.0)
	print(current_stream_synchronised.get_sync_stream_volume(1))
	#implement reset

func get_current_stream_synchronised():
	return  stream.get_clip_stream(get_stream_playback().get_current_clip_index())



func fade_volume(out:bool , duration:float = 5):
	print("bus"+ AudioServer.get_bus_name(1))
	print(AudioServer.get_bus_volume_db(1))
	var tween = get_tree().create_tween()
	if out:
		tween.tween_method(func(v): AudioServer.set_bus_volume_db(1, v),init_bus_volume,-100,duration)
		print("out")
	else:
		tween.tween_method(func(v): AudioServer.set_bus_volume_db(1, v),AudioServer.get_bus_volume_db(1),init_bus_volume,duration)
		print("in")
	print(AudioServer.get_bus_volume_db(1))



func _on_debug_list_item_clicked(index, _at_position, _mouse_button_index):
	for key in level.values():
		print(key)
		if key == index:
			queue_specific_track(key)


func _on_game_request_music(random:bool = false, level_type:level = level.MENU):
	
	if random:
		queue_random_track()
	else:
		queue_specific_track(level_type)


func _on_fade_in_button_pressed() -> void:
	fade_volume(false, 1)



func _on_fade_out_button_pressed() -> void:
	fade_volume(true, 1)
