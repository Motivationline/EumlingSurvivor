extends Control

@onready var renderScaleSlider: HSlider = $RenderScaleSlider

func _applyRenderScale(_scale: float) -> void:
	var viewport: Viewport = get_viewport()
	viewport.scaling_3d_scale = _scale


func _on_render_scale_slider_value_changed(value: float) -> void:
	_applyRenderScale(renderScaleSlider.value)
