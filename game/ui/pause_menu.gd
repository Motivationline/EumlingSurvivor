extends Control

@onready var inv: Inv = preload("res://game/ui/inventory/playerInv.tres")
@onready var slots: Array = $TabContainer/Acquired/NinePatchRect/GridContainer.get_children()

func _ready():
	update_slots()
	close ()

# open menu

func resume():
	get_tree().paused = false

func pause():
	get_tree().paused = true

func testEsc():
	if Input.is_action_just_pressed("esc") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("esc") and get_tree().paused:
		resume()

func _on_ResumeButton_pressed():
	resume()

func _on_HomeButton_pressed():
	get_tree().quit()	

#inventory

var is_open = false

func update_slots():
	for p in range(min(inv.items.size(), slots.size())):
		slots[p].update(inv.items[p])
	
func _process(_delta):
	if Input.is_action_just_pressed("openPauseMenu"):
		if is_open:
			close()
		else:
			open()

func open():
	self.visible = true
	is_open = true
	
func close():
		visible = false
		is_open = false


func _on_home_button_pressed() -> void:
	pass # Replace with function body.


func _on_music_button_pressed() -> void:
	pass # Replace with function body.
