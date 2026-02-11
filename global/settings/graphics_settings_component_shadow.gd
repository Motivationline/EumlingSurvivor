class_name GraphicsSettingsComponentShadow extends GraphicsSettingsComponent

func apply(value):
	var parent := get_parent()
	if parent is DirectionalLight3D:
		match value:
			GraphicsSettings.SHADOW_OPTIONS.OFF, GraphicsSettings.SHADOW_OPTIONS.LOW:
				parent.shadow_enabled = false
			GraphicsSettings.SHADOW_OPTIONS.HIGH:
				parent.shadow_enabled = true
	if parent is Decal:
		match value:
			GraphicsSettings.SHADOW_OPTIONS.LOW:
				toggle(true)
			GraphicsSettings.SHADOW_OPTIONS.OFF, GraphicsSettings.SHADOW_OPTIONS.HIGH:
				toggle(false)

func get_setting() -> GraphicsSettings.SETTING:
	return GraphicsSettings.SETTING.SHADOW
