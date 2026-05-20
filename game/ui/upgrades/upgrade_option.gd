extends TextureButton
class_name UpgradeOption

@export var cards: Dictionary[Enum.EUMLING_TYPE, PackedScene] = {}
const CARD_BASE = preload("uid://umtjixecg24")
@export var textures: Dictionary[Enum.UPGRADE, Texture] = {}

func setup(upgrade: Upgrade):
	var scene = cards.get(upgrade.path)
	if not scene:
		scene = CARD_BASE
	var card: Node3D = scene.instantiate()
	$SubViewport.add_child(card)

	card.find_child("Text").text = upgrade._to_string()

	var texture = textures.get(upgrade.type)
	if texture:
		card.find_child("UpgradeImage").texture = texture
