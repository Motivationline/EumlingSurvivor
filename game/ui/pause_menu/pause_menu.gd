extends Control
var is_open = false

func _ready():
	close ()
	
func _process(_delta):
	if Input.is_action_just_pressed("scribbleOverlayUpgrade"):
		if is_open:
			close()
		else:
			open()

func open():
	visible = true
	is_open = true
	Engine.time_scale = 0
	
func close():
	Engine.time_scale = 1
	visible = false
	is_open = false


func _on_resume_button_pressed() -> void:
	close()
