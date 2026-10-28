class_name RIASECResult extends Control 

@export var icons: Dictionary[Enum.EUMLING_TYPE, Texture]
@export var fillup_duration: float = 0.3

var original_modulate: Color
var progress_value: float

func _ready() -> void:
	original_modulate = modulate
	modulate = Color.TRANSPARENT

func setup(type: Enum.EUMLING_TYPE, amount: float, max_value: float):
	%Icon.texture = icons.get(type)
	%ProgressBar.max_value = max_value
	progress_value = amount
	
func appear() -> void:
	modulate = original_modulate
	var tween := create_tween()
	tween.tween_property(%ProgressBar, "value", progress_value, fillup_duration)
	await tween.finished
