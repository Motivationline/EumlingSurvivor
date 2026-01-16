extends PanelContainer
class_name UpgradeOption

@onready var title: Label = %Title
@onready var subtitle: Label = %Subtitle
@onready var info: RichTextLabel = %Info

func setup(upgrade: Upgrade):
	title.text = Enum.UPGRADE.keys()[upgrade.type]
	subtitle.text = ""

	if upgrade.method == Enum.UPGRADE_METHOD.ABSOLUTE:
		info.text = "+ " if upgrade.value > 0 else "- "
	else:
		info.text = "x "
	info.text += str(upgrade.value)
	theme_type_variation = Enum.RARITY.keys()[upgrade.rarity]
