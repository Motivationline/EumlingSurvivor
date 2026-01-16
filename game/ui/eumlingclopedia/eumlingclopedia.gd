extends Control
const REVEAL_SEED = preload("uid://8jbavxhvd2hx")
@onready var book: Control = $Book

func _ready() -> void:
	setup_buttons()
	#check_for_new_eumlings([randi_range(0, 4), randi_range(0, 4)])

func _on_close_button_pressed() -> void:
	Main.controller.load_scene(Main.controller.main_menu, false)

func setup_buttons():
	pass

func check_for_new_eumlings(new_eumlings: Array[int]):
	book.hide();
	for e in new_eumlings:
		var reveal = REVEAL_SEED.instantiate()
		reveal.which_eumling_is_shown = e;
		add_child(reveal)
		await reveal.completed
		reveal.queue_free()

	book.show();


func _on_gamble_button_pressed() -> void:
	check_for_new_eumlings([randi_range(0, 4)])
