extends TextureButton
class_name UpgradeOption

@export var cards: Dictionary[Enum.EUMLING_TYPE, PackedScene] = {}
const CARD_BASE = preload("uid://umtjixecg24")
@export var textures: Dictionary[Enum.UPGRADE, Texture] = {}
@export var sound_effect_manager : SoundEffectManager

func setup(upgrade: Upgrade, delay: float = 0.0, sound_pos_offset: float = 0.0):
	var scene = cards.get(upgrade.path)
	if not scene:
		scene = CARD_BASE
	var card: Node3D = scene.instantiate()

	card.find_child("Text").text = upgrade._to_string()
	sound_effect_manager.position.x = sound_pos_offset
	var texture = textures.get(upgrade.type)
	if texture:
		card.find_child("UpgradeImage").texture = texture
	
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	mouse_entered.connect(_on_focus_entered)
	mouse_exited.connect(_on_focus_exited)
	
	await get_tree().create_timer(delay).timeout
	$SubViewport.add_child(card)
	sound_effect_manager.play_sound("Reveal")
	if get_parent().get_child(0) == self:
		grab_focus()

func _on_focus_entered():
	scale = Vector2(1.1, 1.1)
	grab_focus()

func _on_focus_exited():
	scale = Vector2(1, 1)
