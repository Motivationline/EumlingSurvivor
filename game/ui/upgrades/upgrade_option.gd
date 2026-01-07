extends PanelContainer
class_name UpgradeOption

@onready var title: Label = $Sprite2D/Title
@onready var subtitle: Label = $Sprite2D/Subtitle
@onready var info: RichTextLabel = $Sprite2D/Info

func setup(upgrade: Upgrade):
	prints(Enum.UPGRADE.keys())
	info.text = "%s: %s %s" % [Enum.UPGRADE.keys()[upgrade.type], Enum.UPGRADE_METHOD.keys()[upgrade.method], upgrade.value]
	theme_type_variation = Enum.RARITY.keys()[upgrade.rarity]
	
