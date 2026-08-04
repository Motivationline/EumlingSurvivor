extends TextureButton
class_name UpgradeOption

@export var cards: Dictionary[Enum.EUMLING_TYPE, PackedScene] = {}
const CARD_BASE = preload("uid://umtjixecg24")
const SPECIAL_ICON_PLACEHOLDER = preload("uid://cmslavw1w4df3")
@export var textures: Dictionary[Enum.UPGRADE, Texture] = {}
@export var sound_effect_manager : SoundEffectManager

func setup_multiple(upgrades: Array, delay: float = 0.0, sound_pos_offset: float = 0.0):
	if upgrades.size() == 0: return
	var card: Node3D = CARD_BASE.instantiate()
	var text = card.find_child("Text")
	text.text = ""
	for i in upgrades.size():
		if i > 0:
			text.text += "\n"
		text.text += upgrades[i]._to_string()	
	card.find_child("UpgradeImage").texture = SPECIAL_ICON_PLACEHOLDER
	card.find_child("Tracker").hide()
	card.find_child("Tag").hide()
	card.find_child("TrackerPointsBackground").hide()
	_shared_setup(card, delay, sound_pos_offset)


func setup(upgrade: Upgrade, delay: float = 0.0, sound_pos_offset: float = 0.0):
	var scene = cards.get(upgrade.path)
	if not scene:
		scene = CARD_BASE
	var card: Node3D = scene.instantiate()

	card.find_child("Text").text = upgrade._to_string()
	var texture = textures.get(upgrade.type)
	if texture:
		card.find_child("UpgradeImage").texture = texture
	var tracker = card.find_child("Tracker");
	if upgrade.path < 0:
		tracker.hide()
		card.find_child("Tag").hide()
		card.find_child("TrackerPointsBackground").hide()

	var tracker_step = Data.game_data.upgrade_path_progress.get(upgrade.path, 0)
	if tracker:
		for i in tracker.get_child_count():
			tracker.get_child(i).visible = i <= tracker_step
		animate_dot(tracker.get_child(tracker_step))
	_shared_setup(card, delay, sound_pos_offset)


func _shared_setup(card: Node3D, delay: float = 0.0, sound_pos_offset: float = 0.0):
	sound_effect_manager.position.x = sound_pos_offset
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

func animate_dot(node: Sprite3D):
	if not node: return
	var tween := create_tween()
	tween.tween_property(node, "scale", node.scale * 1.5, 1.0)
	tween.tween_property(node, "scale", node.scale, 1.0)
	tween.tween_callback(animate_dot.bind(node))
