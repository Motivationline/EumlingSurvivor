@tool
extends EditorPlugin
## Synchronizes enemy values from the configured JSON file with the difficulty overrides stored in the corresponding enemy scenes.

var _is_running: bool = false


func _enter_tree() -> void:
	var config := BalancingConfig
	var command_palette: EditorCommandPalette = EditorInterface.get_command_palette()
	command_palette.add_command(config.SYNC_COMMAND_NAME, config.SYNC_COMMAND_KEY, _synchronize)
	command_palette.add_command(config.DRY_RUN_COMMAND_NAME, config.DRY_RUN_COMMAND_KEY, _dry_run)


func _exit_tree() -> void:
	var command_palette: EditorCommandPalette = EditorInterface.get_command_palette()
	command_palette.remove_command(BalancingConfig.SYNC_COMMAND_KEY)
	command_palette.remove_command(BalancingConfig.DRY_RUN_COMMAND_KEY)


func _synchronize() -> void:
	print("Balancing: Starting synchronization.")
	await _run(false)
	print("Balancing: Ending synchronization.")


func _dry_run() -> void:
	print("Balancing: Starting dry run.")
	await _run(true)
	print("Balancing: Ending dry run.")


func _run(dry_run: bool) -> void:
	if _is_running:
		push_warning("Balancing: A synchronization is already running.")
		return

	_is_running = true

	var synchronizer := BalancingSynchronizer.new(dry_run)
	await synchronizer.run()

	_is_running = false
