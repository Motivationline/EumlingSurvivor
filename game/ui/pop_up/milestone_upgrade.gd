extends Control

signal done

var accepts_input: bool = false
@export var stars: Array[Control]
@export var icons: Array[Control]


func setup(type: Enum.EUMLING_TYPE, level: int):
	get_tree().paused = true
	show()
	%MilestoneText.text = "Meilenstein erreicht: %s Eumling Fähigkeiten sind stärker geworden!" % [Enum.EUMLING_TYPE.keys()[type].to_pascal_case()]
	accepts_input = false
	for star in stars:
		star.hide()
	for icon in icons:
		icon.hide()
	
	stars[level].show()
	icons[level].show()


	await get_tree().create_timer(1).timeout
	accepts_input = true

func close():
	get_tree().paused = false
	hide()
	done.emit()
	accepts_input = false

func _input(event: InputEvent) -> void:
	if not accepts_input: return
	if event.is_pressed() and (event is InputEventScreenTouch or event.is_action_pressed("ui_accept")):
		close()
