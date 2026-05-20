extends Resource
class_name Upgrade

@export var type: Enum.UPGRADE
@export var method: Enum.UPGRADE_METHOD
@export var value: float
@export var text: String
@export var path: Enum.EUMLING_TYPE

func _init(_type: Enum.UPGRADE = Enum.UPGRADE.MOVEMENT_SPEED, _method: Enum.UPGRADE_METHOD = Enum.UPGRADE_METHOD.ABSOLUTE, _value: float = 0, _text: String = "%s") -> void:
	type = _type
	method = _method
	value = _value
	text = _text

func apply(_value: float) -> float:
	match method:
		Enum.UPGRADE_METHOD.ABSOLUTE:
			return _value + value
		Enum.UPGRADE_METHOD.MULTIPLIER:
			return _value * value
	
	return _value


func _to_string() -> String:
	return text % [value]

# TODO: remove this? or sort first?
static func apply_all(_value: float, all: Array[Upgrade]) -> float:
	for upgrade in all:
		_value = upgrade.apply(_value)
	
	return _value
