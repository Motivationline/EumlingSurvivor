extends Control

signal done

@export var min_wait_time: float = 0.2

@export var eumling_headline: Label
@export var area_headline: Label

@export var eumling_text : Dictionary[Enum.EUMLING_TYPE, Label] = {}
@export var skill_text : Dictionary[Enum.EUMLING_TYPE, Label] = {}
@export var area : Dictionary[String, Label] = {}

var eumling: Enum.EUMLING_TYPE

func setup_eumling(type: Enum.EUMLING_TYPE):
	eumling_headline.show()
	var e_text = eumling_text.get(type)
	var s_text = skill_text.get(type)

	if e_text: e_text.show()
	if s_text: s_text.show()
	_start_process()

func setup_area(area_name: String):
	area_headline.show()
	var area_label = area.get(area_name)
	if area_label: area_label.show()
	_start_process()

var can_close: bool = false;
func _start_process():
	await get_tree().create_timer(min_wait_time).timeout
	can_close = true

func _end():
	done.emit()
	queue_free()

func _input(event: InputEvent) -> void:
	if event.is_pressed() and (event is InputEventScreenTouch or event.is_action_pressed("ui_accept")):
		if can_close:
			_end()
