extends Control


signal area_chosen(levels: Array[String])
# @onready var grid_container: GridContainer = $Control/CenterContainer/GridContainer
@onready var level_choice_overlay: Control = $LevelChoiceOverlay

var areas = [
	{
		name = "Jungle",
		folder = "3-Jxx-Jungle",
		levels = {
			0: ["J11", "J12", "J13", "J14"],
			1: ["J01", "J02", "J03", "J04", "J05", "J06", "J07", "J08"],
			2: ["J01", "J02", "J03", "J04", "J05", "J06", "J07", "J08"],
			3: ["J01", "J02", "J03", "J04", "J05", "J06", "J07", "J08"],
		},
		boss_levels = {
			0: "JB01",
			1: "JB02",
			2: "JB02",
			3: "JB02",
		},
	},
	{
		name = "Volcano",
		folder = "6-Vxx-Volcano",
		levels = {
			0: ["V01", "V01", "V03", "V04"],
			1: ["V01", "V02", "V03", "V04", "V05", "V06", "V07", "V08"],
			2: ["V01", "V02", "V03", "V04", "V05", "V06", "V07", "V08"],
			3: ["V01", "V02", "V03", "V04", "V05", "V06", "V07", "V08"],
		},
		boss_levels = {
			0: "VB01",
			1: "VB01",
			2: "VB01",
			3: "VB01",
		},
	},
]

func _ready() -> void:
	level_choice_overlay.abort.connect(level_choice_aborted)
	level_choice_overlay.level_chosen.connect(level_chosen)

func setup():
	# for child in grid_container.get_children():
	# 	grid_container.remove_child(child)
	# 	child.queue_free()
	# for area in areas:
	# 	var btn = Button.new()
	# 	btn.text = area.name
	# 	grid_container.add_child(btn)
	# 	btn.pressed.connect(choose_area.bind(area))
	show()

func choose_area(area):
	var level_names: Array[String] = []
	var difficulty: int = Data._active_mini_eumlings.size()
	var amount_levels = difficulty + 3
	var folder_name: String = "res://game/levels/"
	if area.folder:
		folder_name += area.folder + "/"
	var levels = area.levels[difficulty].duplicate()
	levels.shuffle()
	for i in amount_levels:
		if levels.size() == 0: break
		var level = levels.pop_back()
		if not level: break
		level_names.append(folder_name + level + ".tscn")
	var boss_level = area.boss_levels[difficulty]
	level_names.append(folder_name + boss_level + ".tscn")
	area_chosen.emit(level_names)
	
	hide()

func _on_debug_button_pressed() -> void:
	level_choice_overlay.setup()

func level_chosen(level_id: String):
	var level_location = find_file(level_id + ".tscn", "res://game/levels")
	if (level_location != "" and ResourceLoader.exists(level_location)):
		area_chosen.emit([level_location] as Array[String])
		hide()
	else:
		printerr("Level '%s.tscn' doesn't exist in '/game/levels/' or its subfolders. Try again." % level_id)
		level_choice_overlay.setup()

func level_choice_aborted():
	pass

func find_file(file_name: String, folder_location: String = "res://game/levels") -> String:
	# TODO: this might break on exported builds, so this needs to be replaced with something else before release!
	var dir := DirAccess.open(folder_location)
	if dir == null:
		return ""
	var files := dir.get_files()
	if files.has(file_name):
		return folder_location + "/" + file_name
	
	var dirs := dir.get_directories()
	for d in dirs:
		var path = find_file(file_name, folder_location + "/" + d)
		if path != "":
			return path

	return ""


func _on_area_clicked(index: int) -> void:
	choose_area(areas[index])
