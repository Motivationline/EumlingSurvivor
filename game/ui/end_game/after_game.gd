extends CanvasLayer
const RIASEC_RESULT = preload("uid://bg45qiq2skasq")

var results: Array[RIASECResult] = []
var progress: int = 0

signal closed

func _ready() -> void:
	var riasec_progress = Data.game_data.get_riasec_progress_as_sorted_array()
	var max_value = riasec_progress.reduce(func(accum, obj): return max(accum, obj.value), 0)
	for obj in riasec_progress:
		var result = RIASEC_RESULT.instantiate() as RIASECResult
		%RIASECResultContainer.add_child(result)
		result.setup(obj.type, obj.value, max_value)
		results.append(result)
	%NewEumlingInfo.hide()

func _click() -> void:
	if progress < results.size():
		# show next result
		results[progress].appear()
	elif progress == results.size():
		# show eumling page result
		%NewEumlingInfo.show()
	progress += 1

var active_press: bool = false
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_click()
	elif event is InputEventScreenTouch:
		if event.is_pressed() and not active_press:
			active_press = true
			_click()
		if not event.is_pressed() and active_press:
			active_press = false


func setup(eumling: Eumling):
	%EumlexInfoPage.set_info(eumling)


func _on_continue_button_pressed() -> void:
	queue_free()
	closed.emit()
