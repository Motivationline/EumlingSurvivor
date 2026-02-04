@tool
extends EventStrategy
## Activates a child [EntitySpawner]
class_name SpawnEntitiesEventStrategy

var spawner: EntitySpawner

func _ready() -> void:
	_find_child()
	if (Engine.is_editor_hint()):
		child_order_changed.connect(_find_child)
		return

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if (!spawner): warnings.append("Requires an EntitySpawner Node as a child")
	return warnings

func _find_child():
	spawner = null
	for child in get_children():
		if (child is EntitySpawner):
			spawner = child
			break
	update_configuration_warnings()

func execute_event(_data):
	spawner.spawn(parent)
