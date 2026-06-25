extends CanvasLayer
const REVEAL_SEED = preload("uid://8jbavxhvd2hx")

const EUMLING_BUTTON = preload("uid://b6vj3geh4ibvg")
const SELECTION_OVERLAY = preload("uid://kny1jc4mmgwc")

var selection_overlay: TextureRect;

@export var tabs_and_containers: Dictionary[TextureButton, Panel]
@export var eumling_type_and_container: Dictionary[Enum.EUMLING_TYPE, Container]

func _on_tab_pressed(tab: TextureButton):
	if not tab: return
	var panel = tabs_and_containers.get(tab)
	if not panel: return
	highlight_marker(tab)
	show_page(panel)

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
	update_buttons()
	$Book/TabPanel/OrangeButton.pressed.emit()
	$Book/EumlexInfoPage.hide()
	# unlock_new_eumlings([randi_range(0, 4), randi_range(0, 4)])
	selection_overlay = SELECTION_OVERLAY.instantiate()

func _on_close_button_pressed() -> void:
	hide()
	

func update_buttons():
	for container in eumling_type_and_container.values():
		for old_btn in container.get_children():
			old_btn.queue_free()
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

	if eumling.progress == Enum.EUMLING_UNLOCK_PROGRESS.UNLOCKED:
		reveal_new_eumling(eumling, btn)
		Data.reveal_eumling(eumling)

	$Book/EumlexInfoPage.show()
	$Book/EumlexInfoPage.set_info(eumling)

func reveal_new_eumling(eumling: Eumling, btn: EumlingButton):
	if not eumling: return
	if not eumling.progress == Enum.EUMLING_UNLOCK_PROGRESS.UNLOCKED: return
	$Book.hide();
	
	var reveal = REVEAL_SEED.instantiate()
	add_child(reveal)
	reveal.setup(eumling)
	await reveal.completed
	reveal.queue_free()
	# GlobalMusicManager.request_music(SongList.TRACK.MENU,MusicTransition.crossfade(1.0))
	# update_buttons()
	eumling.progress = Enum.EUMLING_UNLOCK_PROGRESS.SEEN
	btn.update_visuals()
	$Book.show();


# func _unhandled_key_input(event: InputEvent) -> void:
# 	if event.is_action_pressed("debug_gamble"):
# 		unlock_new_eumlings([randi_range(0, 5) as Enum.EUMLING_TYPE])
