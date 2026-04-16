class_name StatusVisualsPlayer extends StatusVisuals



@onready var reloadbar: TextureProgressBar = $SubViewport/ReloadBar

var reload_progress: float = 1:
	set = _set_reload_progress

func _set_reload_progress(value: float):
	reload_progress = value
	if(reloadbar):
		reloadbar.value = value
		if value >= reloadbar.max_value:
			reloadbar.hide()
		else:
			reloadbar.show()
