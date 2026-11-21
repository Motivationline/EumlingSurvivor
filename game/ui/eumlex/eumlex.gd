extends CanvasLayer

const EUMLING_BUTTON = preload("uid://b6vj3geh4ibvg")
const SELECTION_OVERLAY = preload("uid://kny1jc4mmgwc")

var selection_overlay: TextureRect
signal closed

@export var tabs_and_containers: Dictionary[TextureButton, Panel]
@export var eumling_type_and_container: Dictionary[Enum.EUMLING_TYPE, Container]
@export var sound_effect_manager: SoundEffectManager
signal eumling_clicked(eumling: Eumling)

var close_button: TextureButton
var current_tab: TextureButton

var close_button_neighbours: Array[EumlingButton]


func _on_tab_pressed(tab: TextureButton):
	if not tab: return
	current_tab = tab
	var panel = tabs_and_containers.get(tab)
	if not panel: return
	highlight_marker(tab)
	show_page(panel)
	sound_effect_manager.play_sound("TurnPage")
	panel.find_child("GridContainer").get_child(0).grab_focus()

	
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
	close_button = %CloseButton
	current_tab = tabs_and_containers.keys()[0]
	_update_buttons()
	%EumlexInfo.hide()
	# unlock_new_eumlings([randi_range(0, 4), randi_range(0, 4)])
	selection_overlay = SELECTION_OVERLAY.instantiate()
	_update_type_counters_and_new_markings()
	$Book/TabPanel/OrangeButton.pressed.emit.call_deferred()
	
	close_button.focus_entered.connect(selection_overlay.hide)
	InputMethodDetector.refresh_sensitive_nodes()


func _on_close_button_pressed() -> void:
	sound_effect_manager.play_sound("Close")
	hide()
	closed.emit()

func update_visuals():
	sound_effect_manager.play_sound("Open")
	_update_buttons()
	_update_type_counters_and_new_markings()
	$Book/CloseButton.grab_focus()

func _update_buttons():
	if selection_overlay and selection_overlay.get_parent():
		selection_overlay.get_parent().remove_child(selection_overlay)
	for container in eumling_type_and_container.values():
		Utils.remove_all_children(container)
	Data.sort_eumlings()
	for category: Array in Data.eumlings.values():
		for eumling in category:
			setup_button(eumling)

	for btn in close_button_neighbours:
		if not btn.hidden:
			close_button.focus_neighbor_bottom = btn.get_path()
			close_button.focus_neighbor_left = btn.get_path()

func _shortcut_input(event) -> void:
	if event.is_action_pressed("debug_unlock_eumlex"):
		for type in Data._locked_eumlings:
			for i in Data._locked_eumlings[type].size():
				Data._unlock_eumling(type)
				
		update_visuals()

func _unhandled_input(event: InputEvent) -> void:
	if visible:
		if event.is_action_pressed("cycle_ui_left"):
			cycle_page(-1)
		elif event.is_action_pressed("cycle_ui_right"):
			cycle_page(1)

func cycle_page(_count: int) -> void:
	var current_index: int = tabs_and_containers.keys().find(current_tab)
	var next_tab: TextureButton = tabs_and_containers.keys()[(current_index + _count) % tabs_and_containers.size()]
	_on_tab_pressed(next_tab)


func setup_button(eumling: Eumling):
	var container: GridContainer = eumling_type_and_container.get(eumling.type)
	if not container: return
	var btn: EumlingButton = EUMLING_BUTTON.instantiate()
	btn.eumling = eumling
	container.add_child(btn)

	var child_id: int = container.get_children().find(btn)
	if child_id < container.columns:
		btn.focus_neighbor_top = close_button.get_path()
	if child_id % container.columns == 2:
		btn.focus_neighbor_right = close_button.get_path()
		
	btn.focus_entered.connect(select_eumling.bind(btn, eumling))

func select_eumling(btn: EumlingButton, eumling: Eumling):
	if (selection_overlay.get_parent()):
		selection_overlay.get_parent().remove_child(selection_overlay)
	btn.add_child(selection_overlay)
	selection_overlay.show()
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
		# reveal_new_eumling(eumling, btn)
		eumling.progress = Enum.EUMLING_UNLOCK_PROGRESS.SEEN;
		Data.reveal_eumling(eumling)
		_update_type_counters_and_new_markings()
		btn.update_visuals()

	eumling_clicked.emit(eumling)

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
