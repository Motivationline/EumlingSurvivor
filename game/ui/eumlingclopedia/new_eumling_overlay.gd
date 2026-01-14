extends Control

@onready var crack_0: TextureRect = $Crack0
@onready var crack_1: TextureRect = $Crack1
@onready var crack_2: TextureRect = $Crack2
@onready var crack_3: TextureRect = $Crack3
@onready var spot_light_3d: SpotLight3D = $NewEumling/Eumling/SubViewport/Node3D/SpotLight3D
@onready var eumling_name: Label = $NewEumling/EumlingName

@export var light_curve: Curve

var active_press: bool = false
var progress: int = 0

func _ready() -> void:
	hide()
	show_eumling(null)

func show_eumling(_eumling: MiniEumling):
	progress = 0
	next_image()
	spot_light_3d.rotation_degrees.x = -105
	show()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.is_pressed() and not active_press:
			active_press = true
			advance()
		if not event.is_pressed() and active_press:
			active_press = false


func advance():
	if progress >= 4:
		if progress == 99:
			hide()
		return
	progress += 1;
	next_image()
	if progress == 4:
		reveal_emuling()


func next_image():
	crack_0.hide()
	crack_1.hide()
	crack_2.hide()
	crack_3.hide()

	match progress:
		0: crack_0.show()
		1: crack_1.show()
		2: crack_2.show()
		3: crack_3.show()


var passed_time = 0
func reveal_emuling():
	eumling_name.hide()
	spot_light_3d.rotation_degrees.x = -105
	passed_time = 0
	await get_tree().create_timer(light_curve.max_domain).timeout
	await get_tree().create_timer(1).timeout
	eumling_name.show()
	await get_tree().create_timer(1).timeout
	progress = 99

func _process(delta: float) -> void:
	if progress != 4: return
	passed_time += delta
	spot_light_3d.rotation_degrees.x = -105 + light_curve.sample(passed_time) * -30
