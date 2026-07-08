extends CanvasLayer
const REVEAL_SEED = preload("uid://8jbavxhvd2hx")

const EUMLING_BUTTON = preload("uid://b6vj3geh4ibvg")
const SELECTION_OVERLAY = preload("uid://kny1jc4mmgwc")

var selection_overlay: TextureRect;

@export var tabs_and_containers: Dictionary[TextureButton, Panel]
@export var eumling_type_and_container: Dictionary[Enum.EUMLING_TYPE, Container]
@export var sound_effect_manager:SoundEffectManager
signal eumling_revealed

func _on_tab_pressed(tab: TextureButton):
	if not tab: return
	var panel = tabs_and_containers.get(tab)
	if not panel: return
	highlight_marker(tab)
	show_page(panel)
	sound_effect_manager.play_sound("TurnPage")

# Display active page
func show_page(active_page):
	for page in tabs_and_containers.values():
		page.hide()
	active_page.show()
	
# Highlight active Marker
func highlight_marker(active_button):
	for tab in tabs_and_containers.keys():
		tab.scale = Vector2(1, 1)
		tab.position.y = 0
	active_button.position.y = -30

func _ready() -> void:
	_update_buttons()
	$Book/TabPanel/OrangeButton.pressed.emit()
	%EumlexInfo.hide()
	# unlock_new_eumlings([randi_range(0, 4), randi_range(0, 4)])
	selection_overlay = SELECTION_OVERLAY.instantiate()
	_update_type_counters_and_new_markings()


func _on_close_button_pressed() -> void:
	sound_effect_manager.play_sound("Close")
	hide()

func update_visuals():
	sound_effect_manager.play_sound("Open")
	_update_buttons()
	_update_type_counters_and_new_markings()

func _update_buttons():
	if selection_overlay and selection_overlay.get_parent():
		selection_overlay.get_parent().remove_child(selection_overlay)
	for container in eumling_type_and_container.values():
		Utils.remove_all_children(container)
	Data.sort_eumlings()
	for category: Array in Data.eumlings.values():
		for eumling in category:
			setup_button(eumling)


func setup_button(eumling: Eumling):
	var container = eumling_type_and_container.get(eumling.type)
	if not container: return
	var btn = EUMLING_BUTTON.instantiate()
	btn.eumling = eumling
	container.add_child(btn)
	btn.pressed.connect(select_eumling.bind(btn, eumling))

func select_eumling(btn: EumlingButton, eumling: Eumling):
	if (selection_overlay.get_parent()):
		selection_overlay.get_parent().remove_child(selection_overlay)
	btn.add_child(selection_overlay)
	sound_effect_manager.play_sound("SelectEumling")

	%EumlexInfo.show()
	if eumling.progress == Enum.EUMLING_UNLOCK_PROGRESS.LOCKED:
		%EumlexInfo/EumlexInfoPageMissing.show()
		%EumlexInfo/EumlexInfoPageMissing.set_info(eumling)
		%EumlexInfo/EumlexInfoPage.hide()
	else:
		%EumlexInfo/EumlexInfoPage.show()
		%EumlexInfo/EumlexInfoPage.set_info(eumling)
		%EumlexInfo/EumlexInfoPageMissing.hide()

	if eumling.progress == Enum.EUMLING_UNLOCK_PROGRESS.UNLOCKED:
		reveal_new_eumling(eumling, btn)
		Data.reveal_eumling(eumling)


func reveal_new_eumling(eumling: Eumling, btn: EumlingButton):
	if not eumling: return
	if not eumling.progress == Enum.EUMLING_UNLOCK_PROGRESS.UNLOCKED: return
	# $Book.hide();
	%SeedRevealContainer.show()
	GlobalMusicManager.fade_out(1.0,true)
	var reveal = REVEAL_SEED.instantiate()
	%SeedRevealViewport.add_child(reveal)
	reveal.setup(eumling)
	await reveal.completed
	reveal.queue_free()
	GlobalMusicManager.request_music(SongList.TRACK.MENU,MusicTransition.crossfade(1.0))
	# _update_buttons()
	eumling.progress = Enum.EUMLING_UNLOCK_PROGRESS.SEEN
	btn.update_visuals()
	# $Book.show();
	%SeedRevealContainer.hide()
	_update_type_counters_and_new_markings()
	eumling_revealed.emit()


# func _unhandled_key_input(event: InputEvent) -> void:
# 	if event.is_action_pressed("debug_gamble"):
# 		unlock_new_eumlings([randi_range(0, 5) as Enum.EUMLING_TYPE])

func _update_type_counters_and_new_markings():
	for type in eumling_type_and_container.keys():
		var container = eumling_type_and_container.get(type)
		var page = container.get_parent().get_parent()
		var number: Label = page.find_child("NumberCounter")
		var typed_eumlings: Array = Data.eumlings.get(type)
		var total: int = typed_eumlings.size()
		var count: int = typed_eumlings.reduce(func(accum, eumling):
			if eumling.progress == Enum.EUMLING_UNLOCK_PROGRESS.SEEN:
				accum += 1
			return accum
		, 0)
		number.text = "%s/%s" % [count, total]

		var new_eumlings_in_tab: int = typed_eumlings.reduce(func(accum, eumling):
			if eumling.progress == Enum.EUMLING_UNLOCK_PROGRESS.UNLOCKED:
				accum += 1
			return accum
		, 0)
		var new_eumlings_marker = tabs_and_containers.keys()[tabs_and_containers.values().find(page)]
		new_eumlings_marker.get_child(0).visible = new_eumlings_in_tab > 0
