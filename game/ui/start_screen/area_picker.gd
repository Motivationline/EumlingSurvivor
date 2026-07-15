class_name AreaPicker extends Control


signal area_chosen(levels: Array[String])
# @onready var grid_container: GridContainer = $Control/CenterContainer/GridContainer
@onready var level_choice_overlay: Control = $LevelChoiceOverlay

static var areas = [
	{
		name = "Jungle",
		folder = "3-Jxx-Jungle",
		type = Enum.EUMLING_TYPE.ARTISTIC,
		levels = {
			0: ["J01_D0", "J02_D0", "J04_D0", "J05_D0", "J07_D0", "J10_D0", "J11_D0", "J12_D0", "J13_D0", "J14_D0", "J15_D0", "J16_D0", "J19_D0"],
			1: ["J01_D1", "J02_D1", "J04_D1", "J05_D1", "J07_D1", "J10_D1", "J15_D1", "J16_D1", "J17_D1", "J18_D1", "J19_D1", "J20_D1"],
			2: ["J01_D2", "J02_D2", "J03_D2", "J04_D2", "J05_D2", "J06_D2", "J07_D2", "J08_D2", "J10_D2", "J15_D2", "J16_D2", "J19_D2"],
			3: ["J01_D3", "J02_D3", "J03_D3", "J04_D3", "J05_D3", "J06_D3", "J07_D3", "J08_D3", "J10_D3", "J15_D3", "J16_D3", "J17_D3", "J19_D3", "J09_D3"],
		},
		boss_levels = {
			0: "JB00",
			1: "JB01",
			2: "JB02",
			3: "JB03",
		},
	},
	{
		name = "Volcano",
		folder = "6-Vxx-Volcano",
		type = Enum.EUMLING_TYPE.CONVENTIONAL,
		levels = {
			0: ["V01", "V02", "V06", "V07", "V13", "V14", "V15", "V16", "V18", "V05", "V20", "V21"],
			1: ["V01_D1", "V02_D1", "V06_D1", "V07_D1", "V08", "V09", "V11", "V12", "V13_D1", "V14_D1", "V17", "V18_D1", "V22", "V23", "V05_D1", "V20_D1", "V21_D1"],
			2: ["V01_D2", "V02_D2", "V06_D2", "V07_D2", "V08_D2", "V09_D2", "V11_D2", "V12_D2", "V13_D2", "V14_D2", "V17_D2", "V18_D2", "V19", "V22_D2", "V23", "V05_D2", "V20_D2", "V21_D2"],
			3: ["V01_D3", "V02_D3", "V06_D3", "V07_D3", "V08_D3", "V09_D3", "V11_D3", "V12_D3", "V13_D3", "V14_D3", "V17_D3", "V18_D3", "V19", "V22_D3", "V05_D3", "V20_D3", "V21_D3"],
		},
		boss_levels = {
			0: "VB00",
			1: "VB01",
			2: "VB02",
			3: "VB03",
		},
	},
	
	{
		name = "Beach",
		folder = "5-Bxx-Beach",
		type = Enum.EUMLING_TYPE.SOCIAL,
		levels = {
			0: ["B01_D0", "B02_D0", "B03_D0", "B04_D0", "B05_D0", "B06_D0", "B07_D0", "B08_D0", "B09_D0", "B10_D0", "B12_D0", "B13_D0","B14_D0", "B15_D0", "B16_D0", "B17_D0", "B19_D0", "B20_D0"],
			1: ["B01_D1", "B02_D1", "B03_D1", "B04_D1", "B05_D1", "B06_D1", "B07_D1", "B08_D1", "B09_D1", "B10_D1", "B12_D1", "B13_D1","B14_D1", "B15_D1", "B16_D1", "B17_D1",  "B19_D1", "B20_D1"],
			2: ["B01_D2", "B02_D2", "B03_D2", "B04_D2", "B05_D2", "B06_D2", "B07_D2", "B08_D2", "B09_D2", "B10_D2", "B12_D2", "B13_D2","B14_D2", "B15_D2", "B16_D2", "B17_D2",  "B19_D2", "B20_D2"],
			3: ["B01_D3", "B02_D3", "B03_D3", "B04_D3", "B05_D3", "B06_D3", "B07_D3", "B08_D3", "B09_D3", "B10_D3", "B12_D3", "B13_D3","B14_D3", "B15_D3", "B16_D3", "B17_D3",  "B19_D3", "B20_D3"],
		},
		boss_levels = {
			0: "BB00",
			1: "BB01",
			2: "BB02",
			3: "BB03",
		},
	},
	
]

func _ready() -> void:
	level_choice_overlay.abort.connect(level_choice_aborted)
	level_choice_overlay.level_chosen.connect(level_chosen)
	$JungleIsland.grab_focus.call_deferred()

func setup():
	# for child in grid_container.get_children():
	# 	grid_container.remove_child(child)
	# 	child.queue_free()
	# for area in areas:
	# 	var btn = Button.new()
	# 	btn.text = area.name
	# 	grid_container.add_child(btn)
	# 	btn.pressed.connect(choose_area_levels.bind(area))
	show()
	$JungleIsland.grab_focus.call_deferred()

static var current_area

static func choose_area_levels_from_index(index: int) -> Array:
	return choose_area_levels(AreaPicker.areas[index])

static func choose_area_levels(area) -> Array:
	current_area = area
	current_area.type = Enum.EUMLING_TYPE.values().pick_random() # TODO remove this when all 6 areas are in game
	var level_names: Array = []
	var difficulty: int = Data.game_data.difficulty
	var amount_levels = difficulty + 3
	var folder_name: String = "res://game/levels"
	if area.folder:
		folder_name += "/" + area.folder
	var levels = area.levels[difficulty].duplicate()
	levels.shuffle()
	for i in amount_levels:
		if levels.size() == 0: break
		var level = levels.pop_back()
		if not level: break
		var level_id: String = find_file(level + ".tscn", folder_name)
		if level_id == "":
			printerr("Couldn't find level %s in folder %s or its subfolders. Make sure it's there or remove it from the area picker list." % [level, folder_name])
			i -= 1;
			continue
		level_names.append({id = level_id, difficulty = difficulty})
	var boss_level = area.boss_levels[difficulty]
	var boss_level_location = find_file(boss_level + ".tscn", folder_name)
	level_names.append({id = boss_level_location, difficulty = difficulty})
	return level_names


func _on_debug_button_pressed() -> void:
	level_choice_overlay.setup()

func level_chosen(level_id: String):
	var split = level_id.split(".")
	level_id = split[0]
	var difficulty = 0
	if split.size() > 1:
		difficulty = int(split[1])
	var level_location = AreaPicker.find_file(level_id + ".tscn", "res://game/levels")
	if (level_location != "" and ResourceLoader.exists(level_location)):
		area_chosen.emit([ {id = level_location, difficulty = difficulty}])
		hide()
	else:
		printerr("Level '%s.tscn' doesn't exist in '/game/levels/' or its subfolders. Try again." % level_id)
		level_choice_overlay.setup()

func level_choice_aborted():
	pass

static func find_file(file_name: String, folder_location: String = "res://game/levels") -> String:
	# TODO: this might break on exported builds, so this needs to be replaced with something else before release!
	var dir := DirAccess.open(folder_location)
	if dir == null:
		return ""
	var files := dir.get_files()
	if files.has(file_name):
		return folder_location + "/" + file_name
	if files.has((file_name + ".remap")):
		return folder_location + "/" + file_name
	
	var dirs := dir.get_directories()
	for d in dirs:
		var path = find_file(file_name, folder_location + "/" + d)
		if path != "":
			return path

	return ""


func _on_area_clicked(index: int) -> void:
	var level_names = choose_area_levels_from_index(index)
	area_chosen.emit(level_names)
	hide()
