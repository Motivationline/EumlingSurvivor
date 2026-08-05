class_name GraphicsSettingsComponentDepthOfField extends GraphicsSettingsComponent

func apply(value):
	var parent := get_parent()
	if parent is Camera3D:
		var camera: Camera3D = parent

		if camera.attributes is CameraAttributesPractical:
			var dof_enabled: bool = value != GraphicsSettings.DEPTH_OF_FIELD_OPTIONS.OFF  && value != GraphicsSettings.DEPTH_OF_FIELD_OPTIONS.LOW
			var attributes: CameraAttributesPractical = camera.attributes
			attributes.dof_blur_far_enabled = dof_enabled
			attributes.dof_blur_near_enabled = dof_enabled

		if camera.compositor != null:
			var effects: Array[CompositorEffect] = camera.compositor.compositor_effects
			var i: int = effects.find_custom(func(item): return item is DepthOfFieldExperimental)
			if i == -1:
				return
			effects[i].enabled = value == GraphicsSettings.DEPTH_OF_FIELD_OPTIONS.LOW


func get_setting() -> GraphicsSettings.SETTING:
	return GraphicsSettings.SETTING.DEPTH_OF_FIELD
