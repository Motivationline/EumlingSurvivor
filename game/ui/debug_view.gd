extends CanvasLayer

func show_upgrades():
	get_tree().paused = true

	%UpgradeTypeButton.clear()
	for type in Enum.UPGRADE.values():
		%UpgradeTypeButton.add_item(Enum.UPGRADE.keys()[type], type)
	show()

func apply_upgrade(upgrade: Upgrade):
	Player.player.add_upgrade(upgrade)

func enable():
	show()
	get_tree().paused = true

func clear_eumlings():
	Data.game_data.active_mini_eumlings.clear()
	Data.active_eumlings_changed.emit(Data.game_data.active_mini_eumlings)
	
	var minis = get_tree().get_nodes_in_group("MiniEumling")
	for m in minis:
		m.queue_free()

func add_eumling(type: Enum.EUMLING_TYPE):
	Data.unlocked_eumling(type)
	var level = get_tree().get_first_node_in_group("Level")
	if level:
		level.spawn_mini_eumling(type)

func heal_player():
	var player = Player.player
	player.health = player.max_health

func player_invulnerability(on: bool):
	var player = Player.player
	player.is_invulnerable = on

func close():
	hide()
	get_tree().paused = false

func set_lvl(lvl, difficulty):
	$LevelLabel.text = lvl + " (" + str(difficulty) + ")"


func _on_add_upgrade_button_pressed() -> void:
	var type = find_child("UpgradeTypeButton").selected
	var method = find_child("UpgradeMethodButton").selected
	var value = find_child("UpgradeValueBox").value
	apply_upgrade(Upgrade.new(type, method, value))

func delete_save() -> void:
	SaveData.reset()
	get_tree().quit()
