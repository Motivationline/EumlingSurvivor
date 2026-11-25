extends Node

class_name AnimatedButton

const REST_SCALE := Vector2.ONE
const HOVER_SCALE := Vector2(1.1, 1.1)
const SQUASH_SCALE := Vector2(1.15, 0.9)

const HOVER_TIME := 0.2
const SQUASH_TIME := 0.1
var _tween: Tween = null
var parent: CanvasItem

func _ready() -> void:
	parent = get_parent()
	parent.offset_transform_enabled = true
	parent.mouse_entered.connect(_on_anim_button_mouse_entered)
	parent.mouse_exited.connect(_on_anim_button_mouse_exited)
	parent.button_down.connect(_on_anim_button_button_down)

func _restart_tween() -> Tween:
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	return _tween

func _on_anim_button_mouse_entered() -> void:
	var tween: Tween = _restart_tween()
	tween.tween_property(parent, ^"offset_transform_scale", HOVER_SCALE, HOVER_TIME).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.parallel().tween_property(parent, ^"rotation_degrees", 1.0 * [-1.0, 1.0].pick_random(), 0.1)

func _on_anim_button_mouse_exited() -> void:
	var tween: Tween = _restart_tween()
	tween.tween_property(parent, ^"offset_transform_scale", REST_SCALE, HOVER_TIME).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.parallel().tween_property(parent, ^"rotation_degrees", 0.0, HOVER_TIME)

func _on_anim_button_button_down() -> void:
	var tween: Tween = _restart_tween()
	tween.tween_property(parent, ^"offset_transform_scale", SQUASH_SCALE, SQUASH_TIME).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(parent, ^"offset_transform_scale", HOVER_SCALE, HOVER_TIME).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT) 
	
	
	
