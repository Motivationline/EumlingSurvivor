extends AudioStreamPlayer



#TODO: 
#-check if current and next track are the same and continue playing,
#-implement level change stuff



enum level {PUZZLE, COMBAT, BOSS, CHASE, PARKOUR}
@export var debug:bool
@onready var debug_ui = $DebugUI
var tracks:Dictionary = {
	0: level.PUZZLE,
	1: level.COMBAT,
	2: level.BOSS,
	3: level.CHASE,
	4: level.PARKOUR
}

func _ready():
	if debug:
		debug_ui.visible = true
	
func start_music(level_type:level):
	
	var next_track = select_track(level_type) +" Intro"
	
	get_stream_playback().switch_to_clip_by_name(next_track)
	print("clipIndex = ",get_stream_playback().get_current_clip_index())
	update_track_trail_volume()

func select_track(level_type:level) -> String:
	var next_track 
	print(level_type)
	match level_type:
		
		level.PUZZLE:
			print("PUZZLE playing")
			return"Puzzle"
			
		
		level.COMBAT:
			print("COMBAT playing")
			return"Combat"
			
		
		level.BOSS:
			print("BOSS playing")
			return"Boss"
			
		
		level.CHASE:
			print("CHASE playing")
			return"Chase"
			
		
		level.PARKOUR:
			print("PARKOUR playing")
			return"Parkour"
	return "not a song"
	


func update_track_trail_volume():
	
	#lower trail volume of previous track
	var current_stream_synchronised = get_current_stream_synchronised()
	if current_stream_synchronised is AudioStreamSynchronized: 
		current_stream_synchronised.set_sync_stream_volume(1,-60.0)
	
	
	await get_tree().create_timer(60).timeout
	
	#raise trail volume of next track
	current_stream_synchronised = get_current_stream_synchronised()
	print(current_stream_synchronised.get_sync_stream_volume(1))
	current_stream_synchronised.set_sync_stream_volume(1,0.0)
	print(current_stream_synchronised.get_sync_stream_volume(1))
	#implement reset

func get_current_stream_synchronised():
	return  stream.get_clip_stream(get_stream_playback().get_current_clip_index())
	
func level_change(target_level:level):
	pass
	#await some signal that transition has occured, then play next track


func _on_debug_list_item_clicked(index, at_position, mouse_button_index):
	for key in tracks.keys():
		if key == index:
			if playing == false:
				play()
			start_music(tracks.get(index))
			
			
			
