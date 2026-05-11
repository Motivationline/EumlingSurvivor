extends Control

@export var backdrops: Dictionary[Enum.EUMLING_TYPE, Texture]

func set_info(eumling: Eumling) -> void:
	$ColorBackground.texture = backdrops.get(eumling.type)
	$Beruf.text = eumling.name
	$BeschreibungText.text = eumling.info
	%EumlingInfoScene.switch_scene(eumling.type)
