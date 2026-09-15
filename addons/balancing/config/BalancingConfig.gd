@tool
class_name BalancingConfig
extends RefCounted

const JSON_FILE: String = "res://addons/balancing/enemy_values.json"
const DIFFICULTY_PROPERTIES: Array[String] = ["introduction", "easy", "medium", "hard"]
const SCENE_SEARCH_ROOT: String = "res://game/enemies"

const SYNC_COMMAND_NAME: String = "Balancing: Synchronize"
const SYNC_COMMAND_KEY: String = "balancing/synchronize"

const DRY_RUN_COMMAND_NAME: String = "Balancing: Dry Run"
const DRY_RUN_COMMAND_KEY: String = "balancing/dry_run"
