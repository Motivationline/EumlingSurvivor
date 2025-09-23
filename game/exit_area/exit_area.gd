extends Area3D

@onready var animationPlayer = $AnimationPlayer

@export var parent:Node3D

func _ready():
	parent.connect("level_cleared", on_level_cleared)
	
func on_level_cleared():
	animationPlayer.play("exit_open")
