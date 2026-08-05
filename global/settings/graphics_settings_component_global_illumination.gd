class_name GraphicsSettingsComponentGlobalIllumination extends GraphicsSettingsComponent

func apply(value):
	var parent := get_parent()
	if parent is Camera3D:
		var camera: Camera3D = parent
		if camera.compositor == null:
			return

		var effects: Array[CompositorEffect] = camera.compositor.compositor_effects
		var i: int = effects.find_custom(func(item): return item is SSAO)
		if i == -1:
			return

		effects[i].enabled = value == GraphicsSettings.GLOBAL_ILLUMINATION_OPTIONS.SSAO

func get_setting() -> GraphicsSettings.SETTING:
	return GraphicsSettings.SETTING.GLOBAL_ILLUMINATION
