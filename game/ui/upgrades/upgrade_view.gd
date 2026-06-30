extends CanvasLayer

signal upgrade_chosen(Upgrade)

const UPGRADE_OPTION = preload("uid://b8nr8s04nxds6")
@onready var upgrade_container: HBoxContainer = %UpgradeContainer
@export var delay_between_cards: float = 0.2
@export_range(0, 5) var amount_of_cards: int = 3

func show_upgrades():
	get_tree().paused = true

	var upgrades: Array[Upgrade] = JsonData.player_upgrade_levels.get(Data.game_data.total_upgrades)

	upgrades.shuffle()
	upgrades.resize(amount_of_cards)

	# figure out which paths can be chosen
	var paths: Array = []
	# 1. for each eumling we have, add one path
	paths.append_array(Data.game_data.active_mini_eumlings)
	# 2. add the current area to the possible upgrade paths
	if AreaPicker.current_area:
		paths.append(AreaPicker.current_area.type)
	# 3. add up to amount of cards of neutral cards
	for i in amount_of_cards:
		paths.append(-1)
	# remove paths that are already maxed out
	for path in paths:
		if Data.game_data.upgrade_path_progress.get(path, 0) >= 10: #TODO get that 10 value from somewhere central instead of hardcoding it
			paths.remove_at(paths.find(path))

	# limit the array to the max amount of cards
	paths.resize(amount_of_cards)

	paths.shuffle()
	for i in upgrades.size():
		upgrades[i].path = paths[i]
	

	Utils.remove_all_children(upgrade_container)

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
	get_tree().paused = false
	upgrade_chosen.emit(option) 
	hide()
