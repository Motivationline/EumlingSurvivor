class_name GraphicsSettingsComponentDepthOfField extends GraphicsSettingsComponent

func apply(value):
	var parent := get_parent()

	if parent is Camera3D and parent.attributes is CameraAttributesPractical:
		var dof_enabled: bool = value != GraphicsSettings.DEPTH_OF_FIELD_OPTIONS.OFF && value != GraphicsSettings.DEPTH_OF_FIELD_OPTIONS.VERY_LOW && value != GraphicsSettings.DEPTH_OF_FIELD_OPTIONS.LOW
		var attributes: CameraAttributesPractical = parent.attributes
		attributes.dof_blur_far_enabled = dof_enabled
		attributes.dof_blur_near_enabled = dof_enabled
	elif parent is MeshInstance3D:
		match parent.name:
			"LowDephtOfField":
				var low_dof_enabled: bool = value == GraphicsSettings.DEPTH_OF_FIELD_OPTIONS.LOW
				toggle(low_dof_enabled)
			"VeryLowDephtOfField":
				var very_low_dof_enabled: bool = value == GraphicsSettings.DEPTH_OF_FIELD_OPTIONS.VERY_LOW
				toggle(very_low_dof_enabled)

func get_setting() -> GraphicsSettings.SETTING:
	return GraphicsSettings.SETTING.DEPTH_OF_FIELD
