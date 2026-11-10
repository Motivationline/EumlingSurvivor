extends Node

enum SETTING {
	RENDER_SCALE,
	DYNAMIC_RENDER_SCALE,
	SHADOW,
	DEPTH_OF_FIELD,
	GLOBAL_ILLUMINATION,
	TARGET_FRAME_RATE
}

enum QUALITY_PRESET {
	LOW,
	MEDIUM,
	HIGH,
	CUSTOM,
	RETRO
}

enum DYNAMIC_RENDER_SCALE {
	ON,
	OFF
}

enum SHADOW_OPTIONS {
	OFF,
	LOW,
	MEDIUM,
	HIGH
}

enum DEPTH_OF_FIELD_OPTIONS {
	OFF,
	LOW,
	MEDIUM,
	HIGH
}

enum GLOBAL_ILLUMINATION_OPTIONS {
	OFF,
	SSAO
}

signal setting_changed(setting, value)

var FRAME_RATE_OPTIONS: Array[int] = get_frame_rate_options();

const SETTINGS_PATH := "user://settings.cfg"
const SECTION := "graphics"

var quality_presets: Dictionary = {
	QUALITY_PRESET.LOW: {
		SETTING.RENDER_SCALE: 0.6,
		SETTING.DYNAMIC_RENDER_SCALE: DYNAMIC_RENDER_SCALE.ON,
		SETTING.SHADOW: SHADOW_OPTIONS.LOW,
		SETTING.DEPTH_OF_FIELD: DEPTH_OF_FIELD_OPTIONS.LOW,
		SETTING.GLOBAL_ILLUMINATION: GLOBAL_ILLUMINATION_OPTIONS.OFF,
		SETTING.TARGET_FRAME_RATE: FRAME_RATE_OPTIONS[0]
	},
	QUALITY_PRESET.MEDIUM: {
		SETTING.RENDER_SCALE: 0.8,
		SETTING.DYNAMIC_RENDER_SCALE: DYNAMIC_RENDER_SCALE.ON,
		SETTING.SHADOW: SHADOW_OPTIONS.MEDIUM,
		SETTING.DEPTH_OF_FIELD: DEPTH_OF_FIELD_OPTIONS.MEDIUM,
		SETTING.GLOBAL_ILLUMINATION: GLOBAL_ILLUMINATION_OPTIONS.OFF,
		SETTING.TARGET_FRAME_RATE: FRAME_RATE_OPTIONS[-2] if FRAME_RATE_OPTIONS.size() > 2 else FRAME_RATE_OPTIONS[0]
	},
	QUALITY_PRESET.HIGH: {
		SETTING.RENDER_SCALE: 1.0,
		SETTING.DYNAMIC_RENDER_SCALE: DYNAMIC_RENDER_SCALE.ON,
		SETTING.SHADOW: SHADOW_OPTIONS.HIGH,
		SETTING.DEPTH_OF_FIELD: DEPTH_OF_FIELD_OPTIONS.HIGH,
		SETTING.GLOBAL_ILLUMINATION: GLOBAL_ILLUMINATION_OPTIONS.OFF,
		SETTING.TARGET_FRAME_RATE: FRAME_RATE_OPTIONS[-1]
	},
	QUALITY_PRESET.CUSTOM: {},
	QUALITY_PRESET.RETRO: {
		SETTING.RENDER_SCALE: 0.1,
		SETTING.DYNAMIC_RENDER_SCALE: DYNAMIC_RENDER_SCALE.OFF,
		SETTING.SHADOW: SHADOW_OPTIONS.OFF,
		SETTING.DEPTH_OF_FIELD: DEPTH_OF_FIELD_OPTIONS.OFF,
		SETTING.GLOBAL_ILLUMINATION: GLOBAL_ILLUMINATION_OPTIONS.SSAO,
		SETTING.TARGET_FRAME_RATE: FRAME_RATE_OPTIONS[0]
	}
}

var settings: Dictionary = quality_presets[QUALITY_PRESET.MEDIUM].duplicate()

var config := ConfigFile.new()

func _ready():
	load_settings()
	
func get_quality_preset() -> QUALITY_PRESET:
	for preset in quality_presets:
		if settings == quality_presets[preset]:
			return preset

	return QUALITY_PRESET.CUSTOM

func set_quality_preset(preset: QUALITY_PRESET) -> void:
	for key in quality_presets[preset]:
		set_setting(key, quality_presets[preset][key])
		
func get_setting(setting: SETTING):
	return settings.get(setting)

func set_setting(setting: SETTING, value):
	if is_same(settings.get(setting), value):
		return

	settings[setting] = value
	apply_setting(setting, value)
	setting_changed.emit(setting, value)

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
		SETTING.TARGET_FRAME_RATE:
			Engine.max_fps = value
			
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
			set_setting(key, config.get_value(SECTION, string_key))
	
	if has_unsaved_changes(): # save newly added settings that where not yet in the config
		save_settings()

func has_unsaved_changes() -> bool:
	for key in settings:
		var string_key = str(key)
		if not config.has_section_key(SECTION, string_key):
			return true;

		if not is_same(config.get_value(SECTION, string_key), settings[key]):
			return true

	return false

func get_frame_rate_options(max_refresh_rate: int = int(DisplayServer.screen_get_refresh_rate()) if DisplayServer.screen_get_refresh_rate() > 0 else 60) -> Array[int]:
	var new_frame_rate_options: Array[int] = []
	for divisor in [4, 3, 2, 1]:
		if max_refresh_rate % divisor != 0:
			continue
		
		var frame_rate: int =  max_refresh_rate / divisor
		if frame_rate < 30:
			continue
		
		new_frame_rate_options.push_back(frame_rate)

	return new_frame_rate_options

## Detect and adjust the graphics settings. This runs a short benchmark in the background.
func detect_settings():
	var benchmark = preload("uid://crtsudpatsbsm").instantiate()
	add_child(benchmark)
	await benchmark.run()
	benchmark.queue_free()

	set_setting(SETTING.RENDER_SCALE, 1.0)
	set_setting(SETTING.DYNAMIC_RENDER_SCALE, DYNAMIC_RENDER_SCALE.OFF)
	set_setting(SETTING.TARGET_FRAME_RATE, FRAME_RATE_OPTIONS[-1])

	var average_frame_time: float = benchmark.average_frame_time
	var target_frame_time := 1000.0 / FRAME_RATE_OPTIONS[-1]

	var score := target_frame_time / average_frame_time
	var preset := int(clamp(score, 1.0, 3.0)) as QUALITY_PRESET
	
	print_rich("[color=cyan][b]Detect Settings[/b][/color] | Average Frame Time: [color=green]%0.2f ms[/color] | Score: [color=yellow]%d[/color] | Preset: [color=magenta][b]%s[/b][/color]" % [average_frame_time, score, preset])

	set_quality_preset(preset)
