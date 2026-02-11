extends Node

enum SETTING {
	GLOBAL_ILLUMINATION,
	RENDER_SCALE,
	SHADOW
}

enum GLOBAL_ILLUMINATION_OPTIONS {
	OFF,
	BAKED,
	SSAO
}

enum SHADOW_OPTIONS {
	OFF,
	LOW,
	HIGH
}

signal setting_changed(setting_name, value)

const SETTINGS_PATH := "user://settings.cfg"
const SECTION := "graphics"

var settings := {
	SETTING.GLOBAL_ILLUMINATION: GLOBAL_ILLUMINATION_OPTIONS.BAKED,
	SETTING.RENDER_SCALE: 1.0,
	SETTING.SHADOW: SHADOW_OPTIONS.HIGH
}

var config := ConfigFile.new()

func _ready():
	load_settings()

func set_setting(setting: SETTING, value):
	if settings.get(setting) == value:
		return

	settings[setting] = value
	apply_setting(setting, value)
	setting_changed.emit(setting, value)

func get_setting(setting: SETTING):
	return settings.get(setting)

func apply_setting(setting: SETTING, value):
	match setting:
		SETTING.RENDER_SCALE:
			var viewport: Viewport = get_viewport()
			viewport.scaling_3d_scale = value
			
func save_settings():
	for key in settings:
		config.set_value(SECTION, str(key), settings[key])	

	config.save(SETTINGS_PATH)

func load_settings():
	var err := config.load(SETTINGS_PATH)
	if err != OK:
		save_settings() # create config file with defaults
		return 

	for key in settings:
		var string_key = str(key)
		if config.has_section_key(SECTION, string_key):
			var value = config.get_value(SECTION, string_key)
			set_setting(key, value)

func has_unsaved_changes() -> bool:
	for key in settings:
		var saved_value = config.get_value(SECTION, str(key))
		if saved_value != settings[key]:
			return true

	return false
