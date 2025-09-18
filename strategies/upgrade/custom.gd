extends Upgrade

class_name CustomUpgrade

var custom: String

func _init(_custom_id) -> void:
	super (Enum.UPGRADE.CUSTOM, Enum.UPGRADE_METHOD.ABSOLUTE, 0)
	custom = _custom_id