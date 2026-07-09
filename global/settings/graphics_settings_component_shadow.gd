class_name GraphicsSettingsComponentShadow extends GraphicsSettingsComponent

func apply(value):
	var parent := get_parent()

	if parent is DirectionalLight3D:
		var shadow_enabled = value != GraphicsSettings.SHADOW_OPTIONS.OFF && value != GraphicsSettings.SHADOW_OPTIONS.LOW
		parent.shadow_enabled = shadow_enabled
	elif parent is Decal:
		var blob_shadow_enabled = value == GraphicsSettings.SHADOW_OPTIONS.LOW
		toggle(blob_shadow_enabled)

func get_setting() -> GraphicsSettings.SETTING:
	return GraphicsSettings.SETTING.SHADOW
