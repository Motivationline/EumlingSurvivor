@tool
extends Level

@export var portals: Array[BossPortal]

func _ready() -> void:
	super()
	spawn_portals()

func _process(_delta: float) -> void:
	if (Engine.is_editor_hint()): return
