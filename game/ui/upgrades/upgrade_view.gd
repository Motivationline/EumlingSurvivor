extends CanvasLayer

signal upgrade_chosen(Upgrade)

const UPGRADE_OPTION = preload("uid://b8nr8s04nxds6")
@onready var upgrade_container: HBoxContainer = $MarginContainer/UpgradeContainer

@export var upgrade_chances: Dictionary = {
	Enum.RARITY.COMMON: 0.45,
	Enum.RARITY.UNCOMMON: 0.3,
	Enum.RARITY.RARE: 0.18,
	Enum.RARITY.EPIC: 0.05,
	Enum.RARITY.LEGENDARY: 0.02,
}

func show_upgrades(possible_upgrades: Array[Upgrade]):
	Engine.time_scale = 0

	var upgrades: Array[Upgrade]
	for i in range(3):
		var value = randf()
		for rarity in Enum.RARITY.values():
			var chance = upgrade_chances.get(rarity)
			value -= chance
			if value <= 0:
				var rarity_upgrades = possible_upgrades.filter(func(upgrade): return upgrade.type == rarity)
				upgrades.push_back(rarity_upgrades.pick_random())
				break

	for child in upgrade_container.get_children():
		upgrade_container.remove_child(child)
		child.free()

	for upgrade in upgrades:
		var upgrade_option = UPGRADE_OPTION.instantiate() as UpgradeOption
		upgrade_container.add_child(upgrade_option)
		upgrade_option.setup(upgrade)
		upgrade_option.gui_input.connect(upgrade_input.bind(upgrade))
	
	show()

func upgrade_input(event: InputEvent, option: Upgrade):
	if not event is InputEventScreenTouch: return
	if not event.pressed: return 
	upgrade_chosen.emit(option) 
	Engine.time_scale = 1
	hide()
