class_name MusicPlayer extends AudioStreamPlayer



#TODO: 



@export var ambientNoisePlayer:AudioStreamPlayer
var current_track:String
var current_env:String
enum LEVEL {
	MENU, 
	COMBAT_ISLAND,
	COMBAT_FOREST, 
	BOSS_GENERIC,
	BOSS_ISLAND, 
	CHASE
}

@export var debug:bool

enum BUS_IDS {MASTER, MUSIC, SFX_ALL, SFX_ENEMIES, SFX_GENERAL, ENVIRONMENT}

@onready var debug_ui = $DebugUI
@onready var track_selector = $DebugUI/TrackSelector
@onready var init_bus_volumes:Array[float] 


func _ready():

	for i in AudioServer.bus_count:
		init_bus_volumes.append(AudioServer.get_bus_volume_db(i))
	if debug:
		debug_setup()
		debug_ui.visible = true


func debug_setup():
	$DebugUI/VolumeMixerButton.show()
	$DebugUI/VolumeMixerButton.disabled = false
	%MasterSlider.value = AudioServer.get_bus_volume_linear(BUS_IDS.MASTER)*100
	%BGMSlider.value = AudioServer.get_bus_volume_linear(BUS_IDS.MUSIC)*100
	%SFXEnemySlider.value = AudioServer.get_bus_volume_linear(BUS_IDS.SFX_ENEMIES)*100
	%SFXGeneralSlider.value = AudioServer.get_bus_volume_linear(BUS_IDS.SFX_GENERAL)*100
	%EnvironmentSlider.value = AudioServer.get_bus_volume_linear(BUS_IDS.ENVIRONMENT)*100
	$DebugUI/TrackSelectorButton.show()
	$DebugUI/TrackSelectorButton.disabled = false
	
	var selector:ItemList = track_selector.find_child("List")
	for type in LEVEL.values():
		selector.add_item(LEVEL.keys()[type])


func start_playback(names:Array[String],with_ambient:bool = true):
	var track_name = names[0]
	var env_name = names[1]
	if playing == false:
		play()
	if track_name != current_track:
		get_stream_playback().switch_to_clip_by_name(track_name)
		
	if env_name != current_env and with_ambient:
		if env_name == "":
			ambientNoisePlayer.stop()
		else:
			ambientNoisePlayer.play()
			ambientNoisePlayer.get_stream_playback().switch_to_clip_by_name(env_name)

	
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
		LEVEL.COMBAT_FOREST:
			selected_track = "CombatForest"
			selected_ambient = "Forest"
		LEVEL.BOSS_GENERIC:
			selected_track = "BossGeneric"
			selected_ambient = "Forest"
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
 
#current_stream_synchronised.set_sync_stream_volume(1,0.0)
	#print(current_stream_synchronised.get_sync_stream_volume(1))
	#implement reset

func get_current_stream_synchronised():
	return  stream.get_clip_stream(get_stream_playback().get_current_clip_index())



func fade_volume(out:bool , duration:float, reduction_db:float = 30):
	#print("bus"+ AudioServer.get_bus_name(1))
	#print(AudioServer.get_bus_volume_db(1))
	var tween = get_tree().create_tween()
	tween.set_ignore_time_scale(true)
	if out:
		tween.tween_method(func(v): AudioServer.set_bus_volume_db(BUS_IDS.MUSIC, v),  init_bus_volumes[BUS_IDS.MUSIC],  -reduction_db,  duration)
		tween.tween_method(func(v): AudioServer.set_bus_volume_db(BUS_IDS.ENVIRONMENT, v),  init_bus_volumes[BUS_IDS.ENVIRONMENT],  -reduction_db,  duration)
		#print("out")
	else:
		tween.tween_method(func(v): AudioServer.set_bus_volume_db(BUS_IDS.MUSIC, v),  AudioServer.get_bus_volume_db(BUS_IDS.MUSIC),  init_bus_volumes[BUS_IDS.MUSIC],  duration)
		tween.tween_method(func(v): AudioServer.set_bus_volume_db(BUS_IDS.ENVIRONMENT, v),  AudioServer.get_bus_volume_db(BUS_IDS.ENVIRONMENT),  init_bus_volumes[BUS_IDS.ENVIRONMENT],  duration)
		#print("in")
	#print(AudioServer.get_bus_volume_db(1))

func fade_in_and_out(length:float):
	fade_volume(true,1)
	await get_tree().create_timer(length-6,true,false,true).timeout
	fade_volume(false,2)


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
	fade_volume(false, 1, 100)



func _on_fade_out_button_pressed() -> void:
	fade_volume(true, 1, 100)


func _on_volume_mixer_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$DebugUI/VolumeMixer.show()
		$DebugUI/VolumeMixer.call_deferred("grab_focus")

	else:
		$DebugUI/VolumeMixer.hide()
		$DebugUI/VolumeMixer.call_deferred("release_focus")



func _on_volume_slider_value_changed(value:float, source:Node) ->void:
	
	match source.name:
		"MasterSlider":

			AudioServer.set_bus_volume_linear(BUS_IDS.MASTER,value/100)

		"BGMSlider":

			AudioServer.set_bus_volume_linear(BUS_IDS.MUSIC,value/100)
		"SFXGeneralSlider":

			AudioServer.set_bus_volume_linear(BUS_IDS.SFX_GENERAL,value/100)
		"SFXEnemySlider":

			AudioServer.set_bus_volume_linear(BUS_IDS.SFX_ENEMIES,value/100)
		"EnvironmentSlider":

			AudioServer.set_bus_volume_linear(BUS_IDS.ENVIRONMENT,value/100)
		


func _on_track_selector_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		track_selector.show()
		track_selector.call_deferred("grab_focus")

	else:
		track_selector.hide()
		track_selector.call_deferred("release_focus")


func _on_mute_toggled(toggled_on, source):
	match source.name:
		"MasterMute":
			
			AudioServer.set_bus_mute(BUS_IDS.MASTER,toggled_on)

		"BGMMute":
			
			AudioServer.set_bus_mute(BUS_IDS.MUSIC,toggled_on)
		"SFXGeneralMute":
			
			AudioServer.set_bus_mute(BUS_IDS.SFX_GENERAL,toggled_on)
		"SFXEnemyMute":

			AudioServer.set_bus_mute(BUS_IDS.SFX_ENEMIES,toggled_on)
		"EnvironmentMute":

			AudioServer.set_bus_mute(BUS_IDS.ENVIRONMENT,toggled_on)
		
