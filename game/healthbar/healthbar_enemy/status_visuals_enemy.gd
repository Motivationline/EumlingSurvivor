
class_name StatusVisualsEnemy extends StatusVisuals

@onready var socialbar: ProgressBar = $SubViewport/SocialBar


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
