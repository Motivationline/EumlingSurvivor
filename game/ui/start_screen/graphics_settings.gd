extends Control

@export var quality_preset_option: OptionButton
@export var render_scale_slider: HSlider
@export var render_scale_output: Label
@export var dynamic_render_scale_option: OptionButton
@export var target_frame_rate_option: OptionButton
@export var global_illumination_option: OptionButton
@export var shadow_option: OptionButton
@export var depth_of_field_option: OptionButton

func _ready() -> void:
	if quality_preset_option:
		quality_preset_option.clear()
		quality_preset_option.add_item("Low", GraphicsSettings.QUALITY_PRESET.LOW)
		quality_preset_option.add_item("Medium", GraphicsSettings.QUALITY_PRESET.MEDIUM)
		quality_preset_option.add_item("High", GraphicsSettings.QUALITY_PRESET.HIGH)
		quality_preset_option.add_item("Custom", GraphicsSettings.QUALITY_PRESET.CUSTOM)
		quality_preset_option.select(quality_preset_option.get_item_index(GraphicsSettings.get_quality_preset()))

	if render_scale_slider:
		render_scale_slider.value = GraphicsSettings.get_setting(GraphicsSettings.SETTING.RENDER_SCALE)

	if global_illumination_option:
		global_illumination_option.clear()
		global_illumination_option.add_item("Off", GraphicsSettings.GLOBAL_ILLUMINATION_OPTIONS.OFF)
		global_illumination_option.add_item("SSAO", GraphicsSettings.GLOBAL_ILLUMINATION_OPTIONS.SSAO)
		global_illumination_option.select(global_illumination_option.get_item_index(GraphicsSettings.get_setting(GraphicsSettings.SETTING.GLOBAL_ILLUMINATION)))

	if shadow_option:
		shadow_option.clear()
		shadow_option.add_item("Off", GraphicsSettings.SHADOW_OPTIONS.OFF)
		shadow_option.add_item("Low", GraphicsSettings.SHADOW_OPTIONS.LOW)
		shadow_option.add_item("Medium", GraphicsSettings.SHADOW_OPTIONS.MEDIUM)
		shadow_option.add_item("High", GraphicsSettings.SHADOW_OPTIONS.HIGH)
		shadow_option.select(shadow_option.get_item_index(GraphicsSettings.get_setting(GraphicsSettings.SETTING.SHADOW)))

	if depth_of_field_option:
		depth_of_field_option.clear()
		depth_of_field_option.add_item("Off", GraphicsSettings.DEPTH_OF_FIELD_OPTIONS.OFF)
		depth_of_field_option.add_item("Low", GraphicsSettings.DEPTH_OF_FIELD_OPTIONS.LOW)
		depth_of_field_option.add_item("Medium", GraphicsSettings.DEPTH_OF_FIELD_OPTIONS.MEDIUM)
		depth_of_field_option.add_item("High", GraphicsSettings.DEPTH_OF_FIELD_OPTIONS.HIGH)
		depth_of_field_option.select(depth_of_field_option.get_item_index(GraphicsSettings.get_setting(GraphicsSettings.SETTING.DEPTH_OF_FIELD)))
	
	if dynamic_render_scale_option:
		dynamic_render_scale_option.clear()
		dynamic_render_scale_option.add_item("On", GraphicsSettings.DYNAMIC_RENDER_SCALE.ON)
		dynamic_render_scale_option.add_item("Off", GraphicsSettings.DYNAMIC_RENDER_SCALE.OFF)
		dynamic_render_scale_option.select(dynamic_render_scale_option.get_item_index(GraphicsSettings.get_setting(GraphicsSettings.SETTING.DYNAMIC_RENDER_SCALE)))

	if target_frame_rate_option:
		target_frame_rate_option.clear()
		for frame_rate in GraphicsSettings.FRAME_RATE_OPTIONS:
			target_frame_rate_option.add_item("%d FPS" % frame_rate, frame_rate);
			
		target_frame_rate_option.select(target_frame_rate_option.get_item_index(GraphicsSettings.get_setting(GraphicsSettings.SETTING.TARGET_FRAME_RATE)))

	GraphicsSettings.setting_changed.connect(on_setting_changed)

func on_setting_changed(setting, value) -> void:
	match setting:
		GraphicsSettings.SETTING.RENDER_SCALE:
			render_scale_slider.value = value
			render_scale_output.text = "%d%%" % (value * 100.0)
		GraphicsSettings.SETTING.GLOBAL_ILLUMINATION:
			global_illumination_option.select(global_illumination_option.get_item_index(value))
		GraphicsSettings.SETTING.SHADOW:
			shadow_option.select(shadow_option.get_item_index(value))
		GraphicsSettings.SETTING.DEPTH_OF_FIELD:
			depth_of_field_option.select(depth_of_field_option.get_item_index(value))
		GraphicsSettings.SETTING.DYNAMIC_RENDER_SCALE:
			dynamic_render_scale_option.select(dynamic_render_scale_option.get_item_index(value))
		GraphicsSettings.SETTING.TARGET_FRAME_RATE:
			target_frame_rate_option.select(target_frame_rate_option.get_item_index(value))

	quality_preset_option.select(quality_preset_option.get_item_index(GraphicsSettings.get_quality_preset()))

func _on_quality_preset_option_item_selected(index: int) -> void:
	GraphicsSettings.set_quality_preset(quality_preset_option.get_item_id(index))

func _on_render_scale_slider_value_changed(value: float) -> void:
	GraphicsSettings.set_setting(GraphicsSettings.SETTING.RENDER_SCALE, value)

func _on_dynamic_render_scale_option_item_selected(index: int) -> void:
	GraphicsSettings.set_setting(GraphicsSettings.SETTING.DYNAMIC_RENDER_SCALE, dynamic_render_scale_option.get_item_id(index))
	
func _on_target_frame_rate_option_item_selected(index: int) -> void:
	GraphicsSettings.set_setting(GraphicsSettings.SETTING.TARGET_FRAME_RATE, target_frame_rate_option.get_item_id(index))

func _on_shadow_option_item_selected(index: int) -> void:
	var option_value = shadow_option.get_item_id(index)
	GraphicsSettings.set_setting(GraphicsSettings.SETTING.SHADOW, option_value)

func _on_depth_of_field_option_item_selected(index: int) -> void:
	var option_value = depth_of_field_option.get_item_id(index)
	GraphicsSettings.set_setting(GraphicsSettings.SETTING.DEPTH_OF_FIELD, option_value)

func _on_global_illumination_option_item_selected(index: int) -> void:
	var option_value = global_illumination_option.get_item_id(index)
	GraphicsSettings.set_setting(GraphicsSettings.SETTING.GLOBAL_ILLUMINATION, option_value)
