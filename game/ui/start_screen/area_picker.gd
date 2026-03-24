extends Control


signal area_chosen(levels: Array[String])
# @onready var grid_container: GridContainer = $Control/CenterContainer/GridContainer
@onready var level_choice_overlay: Control = $LevelChoiceOverlay

var areas = [
	{
		name = "Jungle",
		folder = "3-Jxx-Jungle",
		levels = {
			0: ["J01", "J02", "J04", "J05", "J07", "J09", "J10", "J11", "J12", "J13", "J14", "J15", "J16", "J19"],
			1: ["J01_D1", "J02_D1", "J04_D1", "J05_D1", "J07_D1", "J09_D1", "J10_D1", "J15_D1", "J16_D1", "J17", "J18", "J19_D1", "J20"],
			2: ["J01_D2", "J02_D2", "J03", "J04_D2", "J05_D2", "J06", "J07_D2", "J08", "J09_D2", "J10_D2", "J15_D2", "J16_D2", "J18", "J19_D2"],
			3: ["J01_D3", "J02_D3", "J03", "J04_D3", "J05_D3", "J06", "J07_D3", "J08", "J09_D3", "J10_D3", "J15_D3", "J16_D3", "J17_D3", "J19_D3"],
		},
		boss_levels = {
			0: "JB01",
			1: "JB01",
			2: "JB02",
			3: "JB02",
		},
	},
	{
		name = "Volcano",
		folder = "6-Vxx-Volcano",
		levels = {
			0: ["V01","V02","V06","V07","V13","V14","V15","V18"],
			1: ["V01_D1","V02_D1","V06_D1","V07_D1","V08","V09","V11","V12","V13_D1","V14_D1","V17","V18_D1","V22","V23"],
			2: ["V01_D2","V02_D2","V06_D2","V07_D2","V08_D2","V09_D2","V11_D2","V12_D2","V13_D2","V14_D2","V17_D2","V18_D2","V19","V22_D2","V23","V24"],
			3: ["V01_D3","V02_D3","V06_D3","V07_D3","V08_D3","V09_D3","V11_D3","V12_D3","V13_D3","V14_D3","V17_D3","V18_D3","V19","V22_D3","V24"],
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
	var level_names: Array = []
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
		level_names.append({id = folder_name + level + ".tscn", difficulty = difficulty})
	var boss_level = area.boss_levels[difficulty]
	level_names.append({id = folder_name + boss_level + ".tscn", difficulty = difficulty})
	area_chosen.emit(level_names)
	
	hide()

func _on_debug_button_pressed() -> void:
	level_choice_overlay.setup()

func level_chosen(level_id: String):
	var split = level_id.split(".")
	level_id = split[0]
	var difficulty = 0
	if split.size() > 1:
		difficulty = int(split[1])
	var level_location = find_file(level_id + ".tscn", "res://game/levels")
	if (level_location != "" and ResourceLoader.exists(level_location)):
		area_chosen.emit([ {id = level_location, difficulty = difficulty}])
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
