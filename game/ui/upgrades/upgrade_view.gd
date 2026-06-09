extends CanvasLayer

signal upgrade_chosen(Upgrade)

const UPGRADE_OPTION = preload("uid://b8nr8s04nxds6")
@onready var upgrade_container: HBoxContainer = %UpgradeContainer
@export var delay_between_cards: float = 0.2

func show_upgrades():
	get_tree().paused = true

	var upgrades: Array[Upgrade] = JsonData.player_upgrade_levels.get(Data.total_upgrades)

	upgrades.shuffle()
	upgrades = upgrades.slice(0, 3)

	# TODO: change how paths are chosen
	var paths: Array = Enum.EUMLING_TYPE.values().duplicate()
	paths.shuffle()
	for i in upgrades.size():
		upgrades[i].path = paths[i]
	

	for child in upgrade_container.get_children():
		upgrade_container.remove_child(child)
		child.free()

	for i in upgrades.size():
		var upgrade = upgrades[i]
		var upgrade_option = UPGRADE_OPTION.instantiate() as UpgradeOption
		upgrade_container.add_child(upgrade_option)
		upgrade_option.setup(upgrade, i * delay_between_cards, -2 + i* 2)
		upgrade_option.pressed.connect(upgrade_input.bind(upgrade))
	show()

func upgrade_input(option: Upgrade):
	# if not event is InputEventScreenTouch: return
	# if not event.pressed: return 
	upgrade_chosen.emit(option) 
	get_tree().paused = false
	hide()
