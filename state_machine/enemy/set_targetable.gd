@tool
##Set [param disabled] property of an [AutoAimTarget]
class_name SetTargetableState extends State

##The [AutoAimTarget] Node
@export var auto_aim_target:AutoAimTarget
##The value to set it to
@export var disabled:bool = false


func enter() -> void:
	super()
	auto_aim_target.disabled = disabled

func process(_delta: float) -> State:
	return return_next()
