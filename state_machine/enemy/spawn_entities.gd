@tool
extends State
## Activates a child [EntitySpawner]
##
## Ends when the Spawner finished spawning all Bursts.
class_name SpawnEntitiesState

## How long to wait before starting the spawner
@export var start_delay: float
## How long to wait after the spawner was finished to proceed to the next state
@export var end_delay: float

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := super ()
	if (!spawner): warnings.append("Requires an EntitySpawner Node as a child")
	return warnings

var spawner: EntitySpawner
var done: bool = false

func _ready() -> void:
	child_order_changed.connect(_find_child)

func _find_child():
	spawner = null
	for child in get_children():
		if (child is EntitySpawner):
			spawner = child
			break
	update_configuration_warnings()

func setup(_parent):
	super(_parent)
	_find_child()

func enter() -> void:
	done = false
	if (start_delay > 0): await get_tree().create_timer(start_delay).timeout
	if (spawner): await spawner.spawn(parent, parent.get_parent())
	if (end_delay > 0): await get_tree().create_timer(end_delay).timeout
	done = true

func process(_delta) -> State:
	if (!done): return null
	return return_next()
