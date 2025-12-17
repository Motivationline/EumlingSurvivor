extends PanelContainer
class_name UpgradeOption

@onready var title: Label = $MarginContainer/VBoxContainer/Title
@onready var subtitle: Label = $MarginContainer/VBoxContainer/Subtitle
@onready var info: RichTextLabel = $MarginContainer/VBoxContainer/Info

func setup(upgrade: Upgrade):
	info.text = "%s: %s %s" % [Enum.UPGRADE.keys()[upgrade.type], Enum.UPGRADE_METHOD.keys()[upgrade.method], upgrade.value]
	theme_type_variation = Enum.RARITY.keys()[upgrade.rarity]
	
