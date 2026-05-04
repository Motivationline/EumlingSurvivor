@abstract
class_name Quest extends Node3D

@export var icon: Texture2D
@export var text: String = ""
@export var can_be_repeated: bool = true
@export var temporary_rewards: Array[Upgrade]

signal completed
signal progress(amount: float, max: float)
signal failed

var level: int = 0
var done: bool = false
@abstract
func start()

func complete():
	done = true
	completed.emit()
	if temporary_rewards and temporary_rewards.size() > 0:
		var index: int = clampi(level - 1, 0, temporary_rewards.size() - 1)
		Player.player.add_upgrade(temporary_rewards[index], true)
	end()

func abort():
	end()

func process(_delta: float):
	pass

func end():
	pass

@abstract
func precondition_is_met() -> bool
