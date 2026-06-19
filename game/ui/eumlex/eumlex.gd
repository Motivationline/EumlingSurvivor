extends Control
const REVEAL_SEED = preload("uid://8jbavxhvd2hx")

const EUMLING_BUTTON = preload("uid://b6vj3geh4ibvg")
const EUMLING_PATH = "res://game/eumlings/"
const GRAYSCALE_MATERIAL = preload("uid://bh8hp6lg5oyi8")

var unlocked_eumlings: Array = []
var seen_eumlings: Array = []

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
		tab.scale = Vector2(1,1)
		tab.position.y = 0
	active_button.position.y = -30

func _ready() -> void:
	unlocked_eumlings = SaveData.get_data("unlocked_eumlings", [])
	seen_eumlings = SaveData.get_data("seen_eumlings", [])
	load_eumlings()
	update_buttons()
	$Book/TabPanel/OrangeButton.pressed.emit()
	$Book/EumlexInfoPage.hide()
	# unlock_new_eumlings([randi_range(0, 4), randi_range(0, 4)])

func _on_close_button_pressed() -> void:
	Main.controller.load_scene(Main.controller.main_menu, false)


var locked_eumlings: Dictionary = {
	Enum.EUMLING_TYPE.ARTISTIC: [],
	Enum.EUMLING_TYPE.CONVENTIONAL: [],
	Enum.EUMLING_TYPE.ENTERPRISING: [],
	Enum.EUMLING_TYPE.INVESTIGATIVE: [],
	Enum.EUMLING_TYPE.REALISTIC: [],
	Enum.EUMLING_TYPE.SOCIAL: [],
}
var eumlings: Dictionary = {}

func load_eumlings(current_path: String = ""):
	var path = EUMLING_PATH + current_path
	var files = DirAccess.get_files_at(path);
	for file in files:
		if (file.get_extension() == "remap"):
			file = file.replace(".remap", "")
		if (file.get_extension() == "tres"):
			var eumling = ResourceLoader.load(path + file) as Eumling
			eumlings[eumling.id] = eumling
			if unlocked_eumlings.has(eumling.id):
				eumling.progress = Enum.EUMLING_UNLOCK_PROGRESS.UNLOCKED
			elif seen_eumlings.has(eumling.id):
				eumling.progress = Enum.EUMLING_UNLOCK_PROGRESS.SEEN
			else:
				locked_eumlings[eumling.type].append(eumling)
	var folders := DirAccess.get_directories_at(path)
	for folder in folders:
		load_eumlings(current_path + folder + "/")
	

func update_buttons():
	for container in eumling_type_and_container.values():
		for old_btn in container.get_children():
			old_btn.queue_free()
	
	for id in eumlings:
		setup_button(eumlings[id])


func setup_button(eumling: Eumling):
	var container = eumling_type_and_container.get(eumling.type)
	if not container: return
	var btn = EUMLING_BUTTON.instantiate()
	btn.eumling = eumling
	container.add_child(btn)
	btn.pressed.connect(select_eumling.bind(btn, eumling))

func select_eumling(btn: EumlingButton, eumling: Eumling):
	if eumling.progress == Enum.EUMLING_UNLOCK_PROGRESS.UNLOCKED:
		eumling.progress = Enum.EUMLING_UNLOCK_PROGRESS.SEEN
		unlocked_eumlings.remove_at(unlocked_eumlings.find(eumling.id))
		seen_eumlings.append(eumling.id)
		SaveData.set_data("unlocked_eumlings", unlocked_eumlings)
		SaveData.set_data("seen_eumlings", seen_eumlings)
	btn.eumling = eumling

	$Book/EumlexInfoPage.show()
	$Book/EumlexInfoPage.set_info(eumling)

func unlock_new_eumlings(new_eumlings: Array[Enum.EUMLING_TYPE]):
	if new_eumlings.size() == 0: return
	$Book.hide();
	for e in new_eumlings:
		var eumling = get_eumling_to_unlock(e)
		if not eumling: break
		var reveal = REVEAL_SEED.instantiate()
		reveal.eumling = eumling;
		add_child(reveal)
		await reveal.completed
		reveal.queue_free()
	update_buttons()
	$Book.show();
	new_eumlings.clear()

func get_eumling_to_unlock(type: Enum.EUMLING_TYPE) -> Eumling:
	var types: Array[Enum.EUMLING_TYPE] = [
		Enum.EUMLING_TYPE.ARTISTIC,
		Enum.EUMLING_TYPE.CONVENTIONAL,
		Enum.EUMLING_TYPE.ENTERPRISING,
		Enum.EUMLING_TYPE.INVESTIGATIVE,
		Enum.EUMLING_TYPE.REALISTIC,
		Enum.EUMLING_TYPE.SOCIAL,
	]
	types.remove_at(types.find(type))
	types.shuffle()
	types.push_front(type)

	for t in types:
		if locked_eumlings[t].size() > 0:
			var index = randi_range(0, locked_eumlings[t].size() - 1)
			var eumling = locked_eumlings[t].pop_at(index)
			eumling.progress = Enum.EUMLING_UNLOCK_PROGRESS.UNLOCKED
			unlocked_eumlings.push_back(eumling.id)
			SaveData.set_data("unlocked_eumlings", unlocked_eumlings)
			return eumling
	return null


func _on_gamble_button_pressed() -> void:
	unlock_new_eumlings([randi_range(0, 4) as Enum.EUMLING_TYPE])
