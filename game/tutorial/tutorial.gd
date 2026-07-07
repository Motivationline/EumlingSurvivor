class_name Tutorial extends Node

# EVERYTHING IN HERE WAS DONE VERY QUICKLY WITHOUT MUCH TIME TO PUT THOUGHT INTO IT
# So don't expect any good code. If you think "why did they do it this way?" the answer
# is probably "because we didn't really think about it for more than 2 seconds."

enum PROGRESS {
	NONE,
	FAILED,
	INTRO_VIDEO,
	INTRO_TEXT,
	INTRO_EUMLEX,
	EUMLEX_INTRO,
	EUMLEX_CLICK,
	EUMLEX_CLOSE,
	START_RUN,
	RUN_INTRO,
	RUN_WALK,
	RUN_SHOOT,
	RUN_HIT,
	RUN_AIM,
	RUN_CAGE_DROP,
	RUN_CAGE_OPEN,
	RUN_PAUSE,
	RETURN_EUMLEX,
	COMPLETED,
}

var progress: PROGRESS = PROGRESS.NONE

func save_progress():
	SaveData.set_data("tutorial_progress", progress)


func _ready() -> void:
	progress = SaveData.get_data("tutorial_progress", 0)
	if progress != PROGRESS.COMPLETED:
		initialize()
		start()
	else:
		Main.controller.load_main()
		queue_free()

var quest_timer: Timer
var blocking_overlay: PackedScene

var video: PackedScene
var dialogue_overlay: PackedScene
var main_menu: PackedScene
var main_menu_instance: Node
var tutorial_level: Level
var dialogue: DialogueResource
var eumlex: PackedScene
var eumlex_instance: Node
var player: Player
var quest_overlay: Node
var touch_joystick_overlay: CanvasLayer
var pulse_animator: PackedScene

var level_wrapper: Node

func initialize() -> void:
	video = load("uid://bhtcrhderikbh")
	dialogue_overlay = load("uid://bgv7vexjse7or")
	
	main_menu = load("res://game/ui/main_menu/main_menu.tscn")
	main_menu_instance = main_menu.instantiate()
	main_menu_instance.find_child("EumlexButton").hide()
	main_menu_instance.find_child("SettingsButton").hide()
	main_menu_instance.find_child("paperOverlay").hide()
	main_menu_instance.find_child("arrowOverlay").hide()
	main_menu_instance.find_child("eumlingLogo").hide()
	main_menu_instance.find_child("eumlingLogo2").hide()
	main_menu_instance.find_child("PlayButton").hide()
	main_menu_instance.find_child("ContinueButton").hide()
	main_menu_instance.find_child("main_menu_sozial").hide()
	dialogue = load("uid://byfbiojxgb3wn")
	eumlex = load("uid://ba2ayes40wtdh")
	pulse_animator = load("uid://dolfciwn4ppmn")

	blocking_overlay = load("uid://d05r8yipgc3ya")
	quest_overlay = load("uid://dfijg5cgisnps").instantiate()
	add_child(quest_overlay)
	quest_overlay.hide()
	touch_joystick_overlay = load("uid://bbnggg8d8khce").instantiate()

	level_wrapper = Node.new()
	add_child(level_wrapper)

	quest_timer = Timer.new()
	quest_timer.process_mode = PROCESS_MODE_ALWAYS
	quest_timer.timeout.connect(hide_quest)
	add_child(quest_timer)

func start() -> void:
	GlobalMusicManager.request_music(SongList.TRACK.TUTORIAL,MusicTransition.fade_and_start(1),true,SongList.ENVNOISE.NOTHING)
	progress = PROGRESS.NONE
	var video_instance = video.instantiate()
	progress = PROGRESS.INTRO_VIDEO
	add_child(video_instance)
	await get_tree().create_timer(2).timeout

	add_child(main_menu_instance)
	remove_child(video_instance)
	progress = PROGRESS.INTRO_TEXT
	await show_dialogue("welcome", false)
	intro_eumlex()

func intro_eumlex():
	var btn: TextureButton = main_menu_instance.find_child("EumlexButton")
	progress = PROGRESS.INTRO_EUMLEX
	btn.show()

	var pressed = func():
		eumlex_show()
	block_input_except_for(btn, pressed)
	show_quest("Öffne den Eumlex")

func eumlex_show():
	progress = PROGRESS.EUMLEX_INTRO
	eumlex_instance = eumlex.instantiate()
	add_child(eumlex_instance)
	await complete_quest()
	await show_dialogue("eumlex_intro", false)
	eumlex_click()



func eumlex_click():
	progress = PROGRESS.EUMLEX_CLICK
	var container: GridContainer = eumlex_instance.eumling_type_and_container.get(Enum.EUMLING_TYPE.REALISTIC)
	var button = container.get_child(0)
	var pressed = func():
		button.pressed.emit()
		await get_tree().create_timer(1.5).timeout
		await show_dialogue("eumlex_clicked", false)
		eumlex_find()
	block_input_except_for(button, pressed)

func eumlex_find():
	var page = eumlex_instance.find_child("EumlexInfoPageMissing");
	var cleanup = block_input_except_for(page, func(): pass, false)
	await get_tree().create_timer(3).timeout
	cleanup.call()
	await show_dialogue("eumlex_found", false)
	eumlex_close()


func eumlex_close():
	progress = PROGRESS.EUMLEX_CLOSE
	var button = eumlex_instance.find_child("CloseButton")
	var pressed = func():
		remove_child(eumlex_instance)
		await show_dialogue("play_intro", false)
		run_start()
	block_input_except_for(button, pressed)


func run_start():
	progress = PROGRESS.START_RUN
	main_menu_instance.find_child("paperOverlay").show()
	main_menu_instance.find_child("arrowOverlay").show()

	var button = main_menu_instance.find_child("PlayButton")
	button.show()
	var pressed = func():
		remove_child(main_menu_instance)
		hide_quest()
		load_level()
		await get_tree().create_timer(1).timeout
		await show_dialogue("training_intro")
		run_move()
	block_input_except_for.call_deferred(button, pressed) # calling deferred for the button to be rendered correctly once first
	show_quest("Starte eine neue Runde")

func run_move():
	if Data.is_on_mobile:
		add_child(touch_joystick_overlay)
	touch_joystick_overlay.find_child("AttackController").hide()
	var quest_text = "Bewege dich"
	if Data.is_on_mobile:
		quest_text += " mit dem Joystick auf der linken Bildschirmseite"
	show_quest(quest_text)
	
	var total_distance_moved: float = 0
	var max_distance_needed: float = 7
	var previous_position = Player.player.global_position

	while(true):
		await get_tree().process_frame
		total_distance_moved += previous_position.distance_to(Player.player.global_position)
		previous_position = Player.player.global_position
		quest_progress(total_distance_moved, max_distance_needed)
		if total_distance_moved >= max_distance_needed:
			break
	await complete_quest()
	run_shoot()

func run_shoot():
	progress = PROGRESS.RUN_SHOOT
	# var original = touch_joystick_overlay.find_child("AttackController")
	# var new_button = TextureButton.new()
	# new_button.name = "TapButton"
	# new_button.size = original.touch_detection_region.size
	# new_button.global_position = original.global_position
	# touch_joystick_overlay.add_child(new_button)
	# var tap = original.tap
	# new_button.pressed.connect(func():
	# 	Input.action_press(tap)
	# 	await get_tree().process_frame
	# 	Input.action_release(tap)
	# )

	var quest_text = "Zerstöre den Stein"
	if Data.is_on_mobile:
		quest_text += " indem du auf der rechten Bildschirmseite tippst"
	show_quest(quest_text)
	var rock = tutorial_level.find_child("Breakables").get_child(0)
	rock.died.connect(func():
		await complete_quest()
		run_hit()
	)

func run_hit():
	progress = PROGRESS.RUN_HIT
	show_quest("Besiege den Trainingsdummy")
	var dummy = tutorial_level.find_child("DummyShoot")
	dummy.died.connect(func():
		await complete_quest()
		await show_dialogue("training_aim")
		run_aim()
	)

func run_aim():
	progress = PROGRESS.RUN_AIM
	show_quest("Besiege den letzten Gegner!")
	# touch_joystick_overlay.find_child("TapButton").queue_free()
	touch_joystick_overlay.find_child("AttackController").show()
	var dummy = tutorial_level.find_child("Dummy", true, false)
	dummy.died.connect(func():
		complete_quest()
		run_cage_drop()
	)


func run_cage_drop():
	await get_tree().create_timer(3.5).timeout
	await show_dialogue("eumling_intro")
	show_quest("Rette den Eumling")
	progress = PROGRESS.RUN_CAGE_DROP

func run_cage_open():
	progress = PROGRESS.RUN_CAGE_OPEN
	complete_quest()
	await show_dialogue("eumling_rescued")
	Data.unlocked_eumling(Enum.EUMLING_TYPE.REALISTIC)
	return_to_main_menu()

func return_to_main_menu():
	progress = PROGRESS.RETURN_EUMLEX
	level_wrapper.queue_free()
	player.queue_free()
	add_child(main_menu_instance)
	GlobalMusicManager.set_environment_noise(SongList.ENVNOISE.NOTHING)
	var btn: TextureButton = main_menu_instance.find_child("EumlexButton")
	block_input_except_for(btn, func():
		eumlex_show_again()
	)
	complete_quest()
	show_quest("Trage den Eumling ein")

func eumlex_show_again():
	progress = PROGRESS.RETURN_EUMLEX
	add_child(eumlex_instance)
	eumlex_instance.update_visuals()
	await get_tree().process_frame
	var container: GridContainer = eumlex_instance.eumling_type_and_container.get(Enum.EUMLING_TYPE.REALISTIC)
	var button = container.get_child(0)
	block_input_except_for(button, func():
		button.pressed.emit()
		await eumlex_instance.eumling_revealed
		eumlex_completed()
	)


func eumlex_completed():
	complete_quest()
	GlobalMusicManager.request_music(SongList.TRACK.TUTORIAL,MusicTransition.instant(),true, SongList.ENVNOISE.NOTHING)
	await get_tree().create_timer(2).timeout
	await show_dialogue("tutorial_completed")
	completed()
	
func player_died():
	progress = PROGRESS.FAILED
	await show_dialogue("training_failed")
	progress = PROGRESS.START_RUN
	hide_quest()
	load_level()
	await show_dialogue("training_intro")
	run_move()


func block_input_except_for(element: Control, callable: Callable, animate: bool = true) -> Callable:
	var overlay = blocking_overlay.instantiate()
	add_child(overlay)
	var duplicated_element = element.duplicate()
	var previous_modulate = element.modulate
	element.modulate = Color(0, 0, 0, 0)

	var cleanup = func():
		element.modulate = previous_modulate
		overlay.queue_free()
		callable.call()

	duplicated_element.show()
	if "pressed" in duplicated_element:
		for connection in duplicated_element.pressed.get_connections():
			duplicated_element.pressed.disconnect(connection.callable)
		duplicated_element.pressed.connect(cleanup)

	overlay.add_child(duplicated_element)
	duplicated_element.set_global_position(element.global_position)
	duplicated_element.set_size(element.size)
	duplicated_element.call_deferred("grab_focus")

	if animate:
		var animator = pulse_animator.instantiate()
		duplicated_element.add_child(animator)
		animator.root_node = animator.get_path_to(duplicated_element)
		duplicated_element.offset_transform_enabled = true

	return cleanup

func show_quest(text: String):
	quest_overlay.show()
	quest_overlay.find_child("Text").text = text
	quest_overlay.find_child("CompletedIcon").hide()
	quest_overlay.find_child("ProgressBar").hide()
	if quest_timer:
		quest_timer.stop()

func hide_quest():
	quest_overlay.hide()

func complete_quest():
	quest_overlay.find_child("CompletedIcon").show()
	quest_timer.start(2)
	await quest_timer.timeout

func quest_progress(value: float, maximum: float):
	var progressbar = quest_overlay.find_child("ProgressBar")
	progressbar.value = value
	progressbar.max_value = maximum
	progressbar.show()

func completed():
	progress = PROGRESS.COMPLETED
	save_progress()
	Main.controller.load_main()
	queue_free()

func load_level():
	Utils.remove_all_children(level_wrapper)

	if player:
		player.queue_free()
	player = load("uid://i26vdjehm6ll").instantiate()
	player.died.connect(player_died)
	add_child(player)

	tutorial_level = load("uid://bwlbdn0hs3kcf").instantiate()
	tutorial_level.difficulty = 0
	level_wrapper.add_child(tutorial_level)
	tutorial_level.spawn_player(player)
	
	tutorial_level.level_ended.connect(run_cage_open)

func show_dialogue(id: String, pause: bool = true):
	if pause: get_tree().paused = true
	DialogueManager.show_dialogue_balloon(dialogue, id)
	await DialogueManager.dialogue_ended
	if pause: get_tree().paused = false
