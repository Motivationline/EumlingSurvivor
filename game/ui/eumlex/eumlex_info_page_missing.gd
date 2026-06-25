extends Control

@export var backdrops: Dictionary[Enum.EUMLING_TYPE, Texture]
@export var locations: Dictionary[Enum.EUMLING_TYPE, Texture]

func set_info(eumling: Eumling) -> void:
	$ColorBackground.texture = backdrops.get(eumling.type)

	$Location.texture = locations.get(eumling.type)
