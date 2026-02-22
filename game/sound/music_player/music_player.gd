class_name MusicPlayer extends AudioStreamPlayer





@export var ambientNoisePlayer:AudioStreamPlayer
enum TRACK {
	MENU, 
	COMBAT_ISLAND,
	COMBAT_FOREST, 
	BOSS_GENERIC,
	BOSS_ISLAND, 
	CHASE,
	GAMBA
}

enum TRANSITIONS {
	INSTANT, 
	CROSSFADE
	}


var current_clip:String
var current_track:String
var current_env:String
var clips: Dictionary
var tracks:Dictionary


var default_transition:Dictionary = {
	"from_time" : AudioStreamInteractive.TransitionFromTime.TRANSITION_FROM_TIME_IMMEDIATE,
	"to_time": AudioStreamInteractive.TransitionToTime.TRANSITION_TO_TIME_START,
	"fade_mode": AudioStreamInteractive.FadeMode.FADE_OUT,
	"fade_beats": 1.0,
	}


func _ready():
	#set up track list
	for i in TRACK.size():
		tracks[i] = [ get_clip_names_from_track( TRACK.get( TRACK.keys()[i] )) ]


func start_playback(_names:Array[String], _with_ambient:bool = true):
	var track_name = _names[0]
	var env_name = _names[1]
	if playing == false:
		play()
	if track_name != current_clip:
		get_stream_playback().switch_to_clip_by_name(track_name)
		
	if env_name != current_env and _with_ambient:
		if env_name == "":
			ambientNoisePlayer.stop()
		else:
			ambientNoisePlayer.play()
			
			
			ambientNoisePlayer.get_stream_playback().switch_to_clip_by_name(env_name)

	
	#print("clipIndex = ", get_stream_playback().get_current_clip_index())
	update_track_tail_volume()
	current_clip = track_name
	current_env = env_name



func queue_random_track():
	var next_track = random_track()
	start_playback(next_track)




func queue_specific_track(_track_name:TRACK, _transition:TRANSITIONS = TRANSITIONS.CROSSFADE, _duration:float = 0, _with_env_nose: bool = false):
	var next_track:Array[String] = select_track(_track_name)
	start_playback(next_track)
	
	update_transition(current_track,_transition, _duration, next_track[0])
	
	current_track = next_track[0]
	


func update_transition(_from:String, _type:TRANSITIONS,_duration:float, _to:String = "default") -> void:
	if _to == "default":
		pass
	match _type:
		TRANSITIONS.INSTANT:
			var current_stream = stream as AudioStreamInteractive
			#current_stream.add_transition()
			
			
			
		TRANSITIONS.CROSSFADE:
			pass
	
	
	

func select_track(_track_name:TRACK) -> Array[String]:
	#print(_track_name)
	var selected_track = "Menu"
	var selected_ambient = ""
	match _track_name:
		
		
		TRACK.MENU:
			selected_track = "Menu"
		TRACK.COMBAT_ISLAND:
			selected_track = "CombatIsland"
			selected_ambient = "Island"
		TRACK.COMBAT_FOREST:
			selected_track = "CombatForest"
			selected_ambient = "Forest"
		TRACK.BOSS_GENERIC:
			selected_track = "BossGeneric"
			selected_ambient = "Forest"
		TRACK.BOSS_ISLAND:
			selected_track = "BossIsland"
			selected_ambient = "Island"
		TRACK.CHASE:
			selected_track = "Chase"
		TRACK.GAMBA:
			selected_track = "Gamba Jingle"

	return [(selected_track+" Intro"),selected_ambient]



func get_clip_names_from_track(_track_name:TRACK) -> Array[String]:
	#print(_track_name)
	var selected_track = "Menu"
	match _track_name:
		
		
		TRACK.MENU:
			selected_track = "Menu"
		TRACK.COMBAT_ISLAND:
			selected_track = "CombatIsland"
		TRACK.COMBAT_FOREST:
			selected_track = "CombatForest"
		TRACK.BOSS_GENERIC:
			selected_track = "BossGeneric"
		TRACK.BOSS_ISLAND:
			selected_track = "BossIsland"
		TRACK.CHASE:
			selected_track = "Chase"
		TRACK.GAMBA:
			selected_track = "Gamba Jingle"

	return [(selected_track+" Intro"),(selected_track+" Loop")]





func random_track() -> Array[String]:
	return get_clip_names_from_track(TRACK.values().pick_random())





func update_track_tail_volume():	
	#lower tail volume of previous track
	var current_stream_synchronised = get_current_stream_synchronised()
	if current_stream_synchronised is AudioStreamSynchronized: 
		current_stream_synchronised.set_sync_stream_volume(1,-60.0)
	
	
	await get_tree().create_timer(60).timeout
	
	current_stream_synchronised = get_current_stream_synchronised()




func get_current_stream_synchronised():
	return  stream.get_clip_stream(get_stream_playback().get_current_clip_index())
