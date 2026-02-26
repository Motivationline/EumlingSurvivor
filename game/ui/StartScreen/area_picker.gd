extends Control


signal area_chosen(levels: Array[String])
# @onready var grid_container: GridContainer = $Control/CenterContainer/GridContainer
@onready var level_choice_overlay: Control = $LevelChoiceOverlay

var areas = [
	{
		name = "Jungle",
		folder = "3-Jxx-Jungle",
		levels = ["J01", "J02", "J03", "J04", "J05", "J06", "J07", "J08"],
		boss_levels = ["JB01", "JB02"],
	},
	# {
	# 	name = "Volcano",
	# 	folder = "6-Vxx-Volcano",
	# 	levels = ["V01"],
	# },
	# {
	# 	name = "Testing",
	# 	folder = "",
	# 	levels = ["001", "002", "003", "004", "005"],
	# },
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
	var amount_levels = Data._active_mini_eumlings.size() + 3
	var folder_name: String = "res://game/levels/"
	if area.folder:
		folder_name +=  area.folder + "/"
	var levels = area.levels.duplicate()
	levels.shuffle()
	for i in amount_levels:
		if levels.size() == 0: break
		var level = levels.pop_back()
		if not level: break
		level_names.append(folder_name + level + ".tscn")
	var boss_level = area.boss_levels[clampi(Data._active_mini_eumlings.size(), 0, area.boss_levels.size() - 1)]
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


func _on_jungle_pressed() -> void:
	choose_area(areas[0])
