class_name GraphicsSettingsComponentGlobalIllumination extends GraphicsSettingsComponent

func apply(value):
	match value:
		GraphicsSettings.GLOBAL_ILLUMINATION_OPTIONS.OFF, GraphicsSettings.GLOBAL_ILLUMINATION_OPTIONS.SSAO:
			toggle(false)
		GraphicsSettings.GLOBAL_ILLUMINATION_OPTIONS.BAKED:
			toggle(true)

func get_setting() -> GraphicsSettings.SETTING:
	return GraphicsSettings.SETTING.GLOBAL_ILLUMINATION
