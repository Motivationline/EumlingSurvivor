
class_name StatusVisualsEnemy extends StatusVisuals

## Show the Healthbar in the UI instead of above the enemy
@export var show_in_ui: bool = false

@onready var socialbar: ProgressBar = $SubViewport/SocialBar


func _ready() -> void:
	healthbars.append($UIOverlay/Healthbar)
	super()
	if show_in_ui:
		# TODO: maybe actually removing these instead of just hiding them is better for performance.
		$Sprite3D.hide()
		$UIOverlay.show()
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
