extends CanvasLayer

@onready var button_container: VBoxContainer = $Control/ScrollContainer/MarginContainer/ButtonContainer

func show_upgrades(player: Player):
	Engine.time_scale = 0
	for child in button_container.get_children():
		button_container.remove_child(child)
		child.queue_free()
	
	var possible_upgrades = player.get_possible_upgrades()
	for upgrade in possible_upgrades:
		var btn: Button = Button.new()
		btn.text = upgrade.to_string()
		button_container.add_child(btn)
		btn.pressed.connect(apply_upgrade.bind(upgrade, player))

	show()

func apply_upgrade(upgrade: Upgrade, player: Player):
	hide()
	Engine.time_scale = 1
	player.add_upgrade(upgrade)
