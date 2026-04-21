@abstract
class_name Quest extends Node3D

@export var icon: Texture2D
@export var text: String = ""
@export var can_be_repeated: bool = true

signal completed
signal progress(amount: float, max: float)
signal failed


var done: bool = false
@abstract
func start()

func complete():
	done = true
	completed.emit()

func abort(): pass

func process():
	pass


@abstract
func precondition_is_met() -> bool
