extends Control

@export var render_scale_slider: HSlider
@export var global_illumination_options: OptionButton
@export var shadow_options: OptionButton
@export var depth_of_field_options: OptionButton

@export var save_button: Button
@export var cancel_button: Button

var pending_changes := {}

func _ready() -> void:
	if render_scale_slider:
		render_scale_slider.value = GraphicsSettings.get_setting(GraphicsSettings.SETTING.RENDER_SCALE)

	if global_illumination_options:
		global_illumination_options.clear()
		global_illumination_options.add_item("Off", GraphicsSettings.GLOBAL_ILLUMINATION_OPTIONS.OFF)
		#global_illumination_options.add_item("Baked", GraphicsSettings.GLOBAL_ILLUMINATION_OPTIONS.BAKED)
		global_illumination_options.add_item("SSAO", GraphicsSettings.GLOBAL_ILLUMINATION_OPTIONS.SSAO)
		global_illumination_options.select(GraphicsSettings.get_setting(GraphicsSettings.SETTING.GLOBAL_ILLUMINATION))

	if shadow_options:
		shadow_options.clear()
		shadow_options.add_item("Off", GraphicsSettings.SHADOW_OPTIONS.OFF)
		shadow_options.add_item("Low", GraphicsSettings.SHADOW_OPTIONS.LOW)
		shadow_options.add_item("Medium", GraphicsSettings.SHADOW_OPTIONS.MEDIUM)
		shadow_options.add_item("High", GraphicsSettings.SHADOW_OPTIONS.HIGH)
		shadow_options.select(shadow_options.get_item_index(GraphicsSettings.get_setting(GraphicsSettings.SETTING.SHADOW)))

	if depth_of_field_options:
		depth_of_field_options.clear()
		depth_of_field_options.add_item("Off", GraphicsSettings.DEPTH_OF_FIELD_OPTIONS.OFF)
		depth_of_field_options.add_item("Low", GraphicsSettings.DEPTH_OF_FIELD_OPTIONS.LOW)
		depth_of_field_options.add_item("Medium", GraphicsSettings.DEPTH_OF_FIELD_OPTIONS.MEDIUM)
		depth_of_field_options.add_item("High", GraphicsSettings.DEPTH_OF_FIELD_OPTIONS.HIGH)
		depth_of_field_options.select(depth_of_field_options.get_item_index(GraphicsSettings.get_setting(GraphicsSettings.SETTING.DEPTH_OF_FIELD)))

	GraphicsSettings.setting_changed.connect(on_setting_changed)
	update_buttons()

func on_setting_changed(setting, value) -> void:
	match setting:
		GraphicsSettings.SETTING.RENDER_SCALE:
			render_scale_slider.value = value
		GraphicsSettings.SETTING.GLOBAL_ILLUMINATION:
			global_illumination_options.select(global_illumination_options.get_item_index(value))
		GraphicsSettings.SETTING.SHADOW:
			shadow_options.select(shadow_options.get_item_index(value))
		GraphicsSettings.SETTING.DEPTH_OF_FIELD:
			depth_of_field_options.select(depth_of_field_options.get_item_index(value))
	update_buttons()

func update_buttons() -> void:
	var has_unsaved_changes = GraphicsSettings.has_unsaved_changes()
	if cancel_button:
		cancel_button.disabled = not has_unsaved_changes
	if save_button:
		save_button.disabled = not has_unsaved_changes

func _on_render_scale_slider_value_changed(value: float) -> void:
	GraphicsSettings.set_setting(GraphicsSettings.SETTING.RENDER_SCALE, value)

func _on_global_illumination_options_item_selected(index: int) -> void:
	var option_value = global_illumination_options.get_item_id(index)
	GraphicsSettings.set_setting(GraphicsSettings.SETTING.GLOBAL_ILLUMINATION, option_value)

func _on_shadow_options_item_selected(index: int) -> void:
	var option_value = shadow_options.get_item_id(index)
	GraphicsSettings.set_setting(GraphicsSettings.SETTING.SHADOW, option_value)

func _on_depth_of_field_options_item_selected(index: int) -> void:
	var option_value = depth_of_field_options.get_item_id(index)
	GraphicsSettings.set_setting(GraphicsSettings.SETTING.DEPTH_OF_FIELD, option_value)

func _on_save_button_pressed() -> void:
	GraphicsSettings.save_settings()
	update_buttons()

func _on_cancel_button_pressed() -> void:
	GraphicsSettings.load_settings()
	update_buttons()
