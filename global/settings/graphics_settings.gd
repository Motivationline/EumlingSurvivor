extends Node

enum SETTING {
	GLOBAL_ILLUMINATION,
	RENDER_SCALE,
	SHADOW,
	DEPTH_OF_FIELD
}

enum SHADOW_OPTIONS {
	OFF,
	LOW,
	MEDIUM,
	HIGH
}

enum DEPTH_OF_FIELD_OPTIONS {
	OFF,
	VERY_LOW,
	LOW,
	MEDIUM,
	HIGH
}

enum GLOBAL_ILLUMINATION_OPTIONS {
	OFF,
	BAKED,
	SSAO
}

signal setting_changed(setting_name, value)

const SETTINGS_PATH := "user://settings.cfg"
const SECTION := "graphics"

var settings := {
	SETTING.RENDER_SCALE: 1.0,
	SETTING.SHADOW: SHADOW_OPTIONS.MEDIUM,
	SETTING.DEPTH_OF_FIELD: DEPTH_OF_FIELD_OPTIONS.LOW,
	SETTING.GLOBAL_ILLUMINATION: GLOBAL_ILLUMINATION_OPTIONS.OFF,
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
		SETTING.SHADOW:
			var shadowSize = -1
			match value:
				SHADOW_OPTIONS.MEDIUM:
					shadowSize = 1024
				SHADOW_OPTIONS.HIGH:
					shadowSize = 2048
			
			if (shadowSize > -1):
				RenderingServer.directional_shadow_atlas_set_size(shadowSize, ProjectSettings.get_setting("rendering/lights_and_shadows/directional_shadow/16_bits"))
		SETTING.DEPTH_OF_FIELD:
			var dof_bokeh_shape = -1
			var dof_quality = -1
			match value:
				DEPTH_OF_FIELD_OPTIONS.MEDIUM:
					dof_bokeh_shape = RenderingServer.DOF_BOKEH_BOX
					dof_quality = RenderingServer.DOF_BLUR_QUALITY_VERY_LOW
				DEPTH_OF_FIELD_OPTIONS.HIGH:
					dof_bokeh_shape = RenderingServer.DOF_BOKEH_HEXAGON
					dof_quality = RenderingServer.DOF_BLUR_QUALITY_LOW
			
			if (dof_bokeh_shape > -1):
				RenderingServer.camera_attributes_set_dof_blur_bokeh_shape(dof_bokeh_shape)
			
			if (dof_quality > -1):
				RenderingServer.camera_attributes_set_dof_blur_quality(dof_quality, ProjectSettings.get_setting("rendering/camera/depth_of_field/depth_of_field_use_jitter"))
			
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
