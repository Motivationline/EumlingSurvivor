@abstract
class_name Quest extends Node3D

@export var icon: Texture2D
@export var text: String = ""
@export var can_be_repeated: bool = true
@export var temporary_reward: Upgrade

signal completed
signal progress(amount: float, max: float)
signal failed


var done: bool = false
@abstract
func start()

func complete():
	done = true
	completed.emit()
	if temporary_reward:
		Player.player.add_upgrade(temporary_reward, true)
	end()

func abort():
	end()

func process(_delta: float):
	pass

func end():
	pass

@abstract
func precondition_is_met() -> bool
