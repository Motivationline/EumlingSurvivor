extends Control

@onready var renderScaleSlider: HSlider = $RenderScaleSlider
@onready var globalIlluminationOptions: OptionButton = $GlobalIlluminationOptions
@onready var shadowOptions: OptionButton = $ShadowOptions
@onready var applyButton: Button = $ApplyButton
@onready var cancelButton: Button = $CancelButton

var pending_changes := {}

func _ready() -> void:
	globalIlluminationOptions.clear()
	globalIlluminationOptions.add_item("Off", GraphicsSettings.GLOBAL_ILLUMINATION_OPTIONS.OFF)
	globalIlluminationOptions.add_item("Baked", GraphicsSettings.GLOBAL_ILLUMINATION_OPTIONS.BAKED)
	globalIlluminationOptions.add_item("SSAO", GraphicsSettings.GLOBAL_ILLUMINATION_OPTIONS.SSAO)

	shadowOptions.clear()
	shadowOptions.add_item("Off", GraphicsSettings.SHADOW_OPTIONS.OFF)
	shadowOptions.add_item("Low", GraphicsSettings.SHADOW_OPTIONS.LOW)
	shadowOptions.add_item("High", GraphicsSettings.SHADOW_OPTIONS.HIGH)
	
	renderScaleSlider.value = GraphicsSettings.get_setting(GraphicsSettings.SETTING.RENDER_SCALE)

	var current_option = GraphicsSettings.get_setting(GraphicsSettings.SETTING.GLOBAL_ILLUMINATION)
	globalIlluminationOptions.select(globalIlluminationOptions.get_item_index(current_option))

	current_option = GraphicsSettings.get_setting(GraphicsSettings.SETTING.SHADOW)
	shadowOptions.select(shadowOptions.get_item_index(current_option))

	GraphicsSettings.setting_changed.connect(on_setting_changed)
	update_save_button()

func on_setting_changed(setting, value) -> void:
	match setting:
		GraphicsSettings.SETTING.RENDER_SCALE:
			renderScaleSlider.value = value
		GraphicsSettings.SETTING.GLOBAL_ILLUMINATION:
			globalIlluminationOptions.select(globalIlluminationOptions.get_item_index(value))
		GraphicsSettings.SETTING.SHADOW:
			shadowOptions.select(shadowOptions.get_item_index(value))
	update_save_button()

func update_save_button() -> void:
	applyButton.disabled = not GraphicsSettings.has_unsaved_changes()

func _on_render_scale_slider_value_changed(value: float) -> void:
	GraphicsSettings.set_setting(GraphicsSettings.SETTING.RENDER_SCALE, value)

func _on_global_illumination_options_item_selected(index: int) -> void:
	var option_value = globalIlluminationOptions.get_item_id(index)
	GraphicsSettings.set_setting(GraphicsSettings.SETTING.GLOBAL_ILLUMINATION, option_value)

func _on_shadow_options_item_selected(index: int) -> void:
	var option_value = shadowOptions.get_item_id(index)
	GraphicsSettings.set_setting(GraphicsSettings.SETTING.SHADOW, option_value)

func _on_apply_button_pressed() -> void:
	GraphicsSettings.save_settings()
	update_save_button()

func _on_cancel_button_pressed() -> void:
	GraphicsSettings.load_settings()
	update_save_button()
