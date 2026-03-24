extends CanvasLayer

@onready var button_container: VBoxContainer = $Control/MarginContainer/VBoxContainer/ScrollContainer/ButtonContainer

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
	player.add_upgrade(upgrade)

func enable():
	show()
	Engine.time_scale = 0

func clear_eumlings():
	Data.end_game()
	var minis = get_tree().get_nodes_in_group("MiniEumling")
	for m in minis:
		m.queue_free()

func add_eumling(type: Enum.EUMLING_TYPE):
	Data.unlocked_eumling(type)
	var level = get_tree().get_first_node_in_group("Level")
	if level:
		level.spawn_mini_eumling(type)

func heal_player():
	var player = get_tree().get_first_node_in_group("Player")
	player.health = player.max_health

func player_invulnerability(on: bool):
	var player = get_tree().get_first_node_in_group("Player")
	player.is_invulnerable = on

func close():
	hide()
	Engine.time_scale = 1

func set_lvl(lvl, difficulty):
	$LevelLabel.text = lvl + " (" + str(difficulty) + ")"
