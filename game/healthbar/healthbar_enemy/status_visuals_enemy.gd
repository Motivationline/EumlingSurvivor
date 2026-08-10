@tool
class_name StatusVisualsEnemy extends StatusVisuals

## Show the Healthbar in the UI instead of above the enemy
@export var show_in_ui: bool = false:
	set(value):
		show_in_ui = value
		notify_property_list_changed()

@export var boss_bar_backdrop: Texture
@export var boss_bar_overlay: Texture

@onready var socialbar: TextureProgressBar = $SubViewport/SocialBar


func _ready() -> void:
	if Engine.is_editor_hint(): return
	healthbars.append($UIOverlay/Healthbar)
	super()
	%Backdrop.hide()
	%Overlay.hide()
	if show_in_ui:
		# TODO: maybe actually removing these instead of just hiding them is better for performance.
		$Sprite3D.hide()
		$UIOverlay.show()
		if boss_bar_backdrop:
			%Backdrop.texture = boss_bar_backdrop
			%Backdrop.show()
		if boss_bar_overlay:
			%Overlay.texture = boss_bar_overlay
			%Overlay.show()
	else:
		$Sprite3D.show()
		$UIOverlay.hide()

var social_progress: float = 0:
	set = _set_social_progress

func _set_social_progress(value: float):
	social_progress = value
	if (socialbar):
		socialbar.value = value
		if (value > 0):
			socialbar.show()
		else:
			socialbar.hide()


func _get_overlay_bar_size() -> Vector2:
	var bar: TextureProgressBar = $UIOverlay/Healthbar/HealthBar
	if bar:
		return bar.size
	return Vector2.ZERO

func _validate_property(property: Dictionary) -> void:
	if property.name in ["boss_bar_backdrop", "boss_bar_overlay"]:
		if not show_in_ui:
			property.usage = PROPERTY_USAGE_NO_EDITOR
