extends Node

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

	player = load("uid://i26vdjehm6ll").instantiate()
	player.died.connect(player_died)
	add_child(player)

	blocking_overlay = load("uid://d05r8yipgc3ya")
	quest_overlay = load("uid://dfijg5cgisnps").instantiate()
	add_child(quest_overlay)
	quest_overlay.hide()
	touch_joystick_overlay = load("uid://bbnggg8d8khce").instantiate()

	level_wrapper = Node.new()
	add_child(level_wrapper)

	quest_timer = Timer.new()
	quest_timer.timeout.connect(hide_quest)
	add_child(quest_timer)

func start() -> void:
	progress = PROGRESS.NONE
	var video_instance = video.instantiate()
	progress = PROGRESS.INTRO_VIDEO
	add_child(video_instance)
	await get_tree().create_timer(2).timeout

	add_child(main_menu_instance)
	remove_child(video_instance)
	progress = PROGRESS.INTRO_TEXT
	DialogueManager.show_dialogue_balloon(dialogue, "welcome")
	await DialogueManager.dialogue_ended
	intro_eumlex()

func intro_eumlex():
	var btn: TextureButton = main_menu_instance.find_child("EumlexButton")
	progress = PROGRESS.INTRO_EUMLEX
	btn.show()

	var pressed = func():
		complete_quest()
		eumlex_show()
	block_input_except_for(btn, pressed)
	show_quest("Öffne den Eumlex")

func eumlex_show():
	progress = PROGRESS.EUMLEX_INTRO
	eumlex_instance = eumlex.instantiate()
	add_child(eumlex_instance)
	DialogueManager.show_dialogue_balloon(dialogue, "eumlex_intro")
	await DialogueManager.dialogue_ended
	eumlex_click()

func eumlex_click():
	progress = PROGRESS.EUMLEX_CLICK
	var container: GridContainer = eumlex_instance.eumling_type_and_container.get(Enum.EUMLING_TYPE.REALISTIC)
	var button = container.get_child(0)
	var pressed = func():
		button.pressed.emit()
		DialogueManager.show_dialogue_balloon(dialogue, "eumlex_clicked")
		await DialogueManager.dialogue_ended
		eumlex_close()
	block_input_except_for(button, pressed)

func eumlex_close():
	progress = PROGRESS.EUMLEX_CLOSE
	var button = eumlex_instance.find_child("CloseButton")
	var pressed = func():
		remove_child(eumlex_instance)
		DialogueManager.show_dialogue_balloon(dialogue, "play_intro")
		await DialogueManager.dialogue_ended
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
		DialogueManager.show_dialogue_balloon(dialogue, "training_intro")
		await DialogueManager.dialogue_ended
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
	
	while(true):
		await get_tree().process_frame
		var direction = Input.get_vector("left", "right", "up", "down")
		if direction != Vector2.ZERO:
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
	show_quest("Besige den Trainingsdummy")
	var dummy = tutorial_level.find_child("DummyShoot")
	dummy.died.connect(func():
		await complete_quest()
		DialogueManager.show_dialogue_balloon(dialogue, "training_aim")
		await DialogueManager.dialogue_ended
		run_aim()
	)

func run_aim():
	progress = PROGRESS.RUN_AIM
	show_quest("Besiege den letzten Gegner!")
	# touch_joystick_overlay.find_child("TapButton").queue_free()
	touch_joystick_overlay.find_child("AttackController").show()
	var dummy = tutorial_level.find_child("Dummy", true, false)
	dummy.died.connect(func():
		await complete_quest()
		DialogueManager.show_dialogue_balloon(dialogue, "eumling_intro")
		await DialogueManager.dialogue_ended
		run_cage_drop()
	)


func run_cage_drop():
	show_quest("Rette den Eumling")
	progress = PROGRESS.RUN_CAGE_DROP

func run_cage_open():
	await complete_quest()
	progress = PROGRESS.RUN_CAGE_OPEN
	DialogueManager.show_dialogue_balloon(dialogue, "eumling_rescued")
	await DialogueManager.dialogue_ended
	return_to_main_menu()

func return_to_main_menu():
	progress = PROGRESS.RETURN_EUMLEX
	level_wrapper.queue_free()
	add_child(main_menu_instance)
	var btn: TextureButton = main_menu_instance.find_child("EumlexButton")
	block_input_except_for(btn, func():
		eumlex_show_again()
	)
	complete_quest()
	show_quest("Trage den Eumling ein")

func eumlex_show_again():
	progress = PROGRESS.RETURN_EUMLEX
	add_child(eumlex_instance)

	complete_quest()
	DialogueManager.show_dialogue_balloon(dialogue, "tutorial_completed")
	await DialogueManager.dialogue_ended
	completed()

	
func player_died():
	progress = PROGRESS.FAILED
	DialogueManager.show_dialogue_balloon(dialogue, "training_failed")
	await DialogueManager.dialogue_ended
	progress = PROGRESS.START_RUN
	load_level()
	DialogueManager.show_dialogue_balloon(dialogue, "training_intro")


func block_input_except_for(element: Control, callable: Callable):
	var overlay = blocking_overlay.instantiate()
	add_child(overlay)
	var duplicated_element = element.duplicate()
	var previous_visibility = element.visible

	var cleanup = func():
		element.visible = previous_visibility
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
	element.hide()

func show_quest(text: String):
	quest_overlay.show()
	quest_overlay.find_child("Text").text = text
	quest_overlay.find_child("CompletedIcon").hide()
	if quest_timer:
		quest_timer.stop()

func hide_quest():
	quest_overlay.hide()

func complete_quest():
	quest_overlay.find_child("CompletedIcon").show()
	quest_timer.start(2)
	await quest_timer.timeout

func completed():
	progress = PROGRESS.COMPLETED
	save_progress()
	Main.controller.load_main()
	queue_free()

func load_level():
	for child in level_wrapper.get_children():
		child.queue_free()

	tutorial_level = load("uid://bwlbdn0hs3kcf").instantiate()
	tutorial_level.difficulty = 0
	level_wrapper.add_child(tutorial_level)
	tutorial_level.spawn_player(player)
	player.revive()
	
	tutorial_level.level_ended.connect(run_cage_open)