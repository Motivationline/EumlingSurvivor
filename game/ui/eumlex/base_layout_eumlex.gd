extends Control
# "Referenz for Buttons/Pages"
@onready var orange_BG = $BookContainer/BookBG/OrangePage
@onready var green_BG = $BookContainer/BookBG/GreenPage
@onready var purple_BG = $BookContainer/BookBG/PurplePage
@onready var yellow_BG = $BookContainer/BookBG/YellowPage
@onready var red_BG = $BookContainer/BookBG/RedPage
@onready var blue_BG = $BookContainer/BookBG/BluePage

@onready var orangeButton = $TabPanel/OrangeButton
@onready var greenButton = $TabPanel/GreenButton
@onready var purpleButton = $TabPanel/PurpleButton
@onready var yellowButton = $TabPanel/YellowButton
@onready var redButton = $TabPanel/RedButton
@onready var blueButton = $TabPanel/BlueButton

@onready var bookBG = $BookContainer/BookBG

func _ready():
	show_page(orange_BG)

# "Starting page"
func show_page(active_page):
	orange_BG.visible = false
	green_BG.visible = false
	purple_BG.visible = false
	yellow_BG.visible = false
	red_BG.visible = false
	blue_BG.visible = false
	active_page.visible = true
	
# "Highlight active Marker"
func highlight_marker(active_Button):
	var buttons = [orangeButton,greenButton,purpleButton,yellowButton,redButton,blueButton]
	for b in buttons:
		b.scale = Vector2(1,1)
		b.position.y = 0
	active_Button.position.y = -30

func _on_orange_button_pressed():
	show_page(orange_BG)
	highlight_marker(orangeButton)
	print("orange is pressed")

func _on_green_button_pressed():
	show_page(green_BG)
	highlight_marker(greenButton)
	print("green is pressed")

func _on_purple_button_pressed():
	show_page(purple_BG)
	highlight_marker(purpleButton)
	print("purple is pressed")
	
func _on_yellow_button_pressed():
	show_page(yellow_BG)
	highlight_marker(yellowButton)
	print("yellow is pressed")

func _on_red_button_pressed() :
	show_page(red_BG)
	highlight_marker(redButton)
	print("red is pressed")

func _on_blue_button_pressed() :
	print("blue is pressed")
	show_page(blue_BG)
	highlight_marker(blueButton)

func _on_close_button_pressed() -> void:
	Main.controller.load_scene(Main.controller.main_menu, false)
