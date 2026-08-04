extends Control

signal upgrade_chosen

var accepts_input: bool = false
@export var stars: Array[Control]
@export var icons: Array[Control]
@export var delay_between_cards: float = 0.2
@onready var upgrade_container: HBoxContainer = %UpgradeContainer
const UPGRADE_OPTION = preload("uid://b8nr8s04nxds6")
var possible_upgrades: Array

func setup(type: Enum.EUMLING_TYPE, level: int):
	get_tree().paused = true
	show()
	if level < 2:
		%MilestoneText.text = "Meilenstein erreicht"
	else:
		%MilestoneText.text = "Letzter Meilenstein erreicht: %s Eumling Fähigkeiten verbessert!" % [Enum.EUMLING_TYPE.keys()[type].to_pascal_case()]
	accepts_input = false
	for star in stars:
		star.hide()
	for icon in icons:
		icon.hide()
	
	stars[level].show()
	icons[level].show()
	%CardsOverlay.hide()
	possible_upgrades = JsonData.player_special_upgrades.get(type).duplicate()


	await get_tree().create_timer(1).timeout
	accepts_input = true

func show_upgrades():
	%CardsOverlay.show()

	Utils.remove_all_children(upgrade_container)

	possible_upgrades.shuffle()
	possible_upgrades.resize(2)

	for i in possible_upgrades.size():
		var upgrade_option = UPGRADE_OPTION.instantiate() as UpgradeOption;
		upgrade_container.add_child(upgrade_option)
		upgrade_option.setup_multiple(possible_upgrades[i], i * delay_between_cards, -1 + i * 2)
		upgrade_option.pressed.connect(_choose.bind(possible_upgrades[i]))

func _choose(chosen_upgrades: Array):
	upgrade_chosen.emit(chosen_upgrades)
	close()


func close():
	get_tree().paused = false
	hide()
	accepts_input = false

func _input(event: InputEvent) -> void:
	if not accepts_input: return
	if event.is_pressed() and (event is InputEventScreenTouch or event.is_action_pressed("ui_accept")):
		if not %CardsOverlay.visible:
			show_upgrades()
