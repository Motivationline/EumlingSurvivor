@tool
extends Level

@export var portals: Array[BossPortal]

func _ready() -> void:
	super()
	for index in portals.size():
		var portal = portals[index]
		portal.entered.connect(entered_portal.bind(index)) 

func _process(_delta: float) -> void:
	if (Engine.is_editor_hint()): return
