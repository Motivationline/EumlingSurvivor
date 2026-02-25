extends Control
const REVEAL_SEED = preload("uid://8jbavxhvd2hx")
@onready var book: Control = $Book

const EUMLING_BUTTON = preload("uid://bppbnuj7gd2bu")
const EUMLING_PATH = "res://game/eumlings/"
const GRAYSCALE_MATERIAL = preload("uid://bh8hp6lg5oyi8")

# TODO: load / save this to disk
var unlocked_eumlings: Array[String] = []
var seen_eumlings: Array[String] = []

func _ready() -> void:
	load_eumlings()
	#unlock_new_eumlings([randi_range(0, 4), randi_range(0, 4)])

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

func load_eumlings():
	var files = DirAccess.get_files_at(EUMLING_PATH);
	for file in files:
		if (file.get_extension() == "remap"):
			file = file.replace(".remap", "")
		if (file.get_extension() == "tres"):
			var eumling = ResourceLoader.load(EUMLING_PATH + file) as Eumling
			eumlings[eumling.id] = eumling
			if unlocked_eumlings.has(eumling.id):
				eumling.progress = Enum.EUMLING_UNLOCK_PROGRESS.UNLOCKED
			elif seen_eumlings.has(eumling.id):
				eumling.progress = Enum.EUMLING_UNLOCK_PROGRESS.SEEN
			else:
				locked_eumlings[eumling.type].append(eumling)
	update_buttons()

func update_buttons():
	for wrapper in %UnlockedEumlings.get_children():
		for old_btn in wrapper.get_child(0).get_children():
			old_btn.queue_free()
	
	for id in eumlings:
		setup_button(eumlings[id])
	
	prints("update buttons")


func setup_button(eumling: Eumling):
	var btn = EUMLING_BUTTON.instantiate()
	btn.eumling = eumling
	%UnlockedEumlings.get_child(eumling.type).get_child(0).add_child(btn)
	btn.pressed.connect(select_eumling.bind(btn, eumling))

func select_eumling(btn: EumlingButton, eumling: Eumling):
	if eumling.progress == Enum.EUMLING_UNLOCK_PROGRESS.UNLOCKED:
		eumling.progress = Enum.EUMLING_UNLOCK_PROGRESS.SEEN
		unlocked_eumlings.remove_at(unlocked_eumlings.find(eumling.id))
		seen_eumlings.append(eumling.id)
	btn.eumling = eumling

	# TODO this should be properly encapsulated, also don't use paths like this
	$Book/Name.text = eumling.name

	$Book/EumlingInfo/Info.text = eumling.info
	$Book/EumlingInfo/EumlingPreview/SubViewport/EumlingInfoScene.switch_scene(eumling.type)
	$Book/EumlingInfo/EumlingPreview.material = GRAYSCALE_MATERIAL if eumling.progress == Enum.EUMLING_UNLOCK_PROGRESS.LOCKED else null

func unlock_new_eumlings(new_eumlings: Array[Enum.EUMLING_TYPE]):
	if new_eumlings.size() == 0: return
	book.hide();
	for e in new_eumlings:
		var eumling = get_eumling_to_unlock(e)
		if not eumling: break
		var reveal = REVEAL_SEED.instantiate()
		reveal.which_eumling_is_shown = eumling.type;
		add_child(reveal)
		await reveal.completed
		reveal.queue_free()
	update_buttons()
	book.show();
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
			return eumling
	return null


func _on_gamble_button_pressed() -> void:
	unlock_new_eumlings([randi_range(0, 4) as Enum.EUMLING_TYPE])
