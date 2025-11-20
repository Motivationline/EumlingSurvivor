extends Enemy

@onready var boss_bugger_visuals: Node3D = $Visuals/BossBugger

@export var MAX_FILL: float = 100

var fluid_level: float = MAX_FILL:
	set(value):
		fluid_level = clampf(value, 0, MAX_FILL)
		boss_bugger_visuals.fluid_level = fluid_level / MAX_FILL
		resource = fluid_level

func _ready() -> void:
	super()
	fluid_level = MAX_FILL

func consume_resource(amount: float):
	fluid_level -= amount
