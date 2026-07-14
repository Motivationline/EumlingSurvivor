extends Control

@export var backdrops: Dictionary[Enum.EUMLING_TYPE, Texture]
@export var tags: Dictionary[Enum.EUMLING_TYPE, Texture]

func set_info(eumling: Eumling) -> void:
	$ColorBackground.texture = backdrops.get(eumling.type)
	%Name.text = eumling.name
	$Beruf.text = eumling.education
	$BeschreibungText.text = eumling.info
	$EumlingPreview.texture = eumling.image
	%ExternalLink.uri = eumling.url

	%Taglines/Tagline1.texture = tags.get(eumling.type)
	%Taglines/Tagline2.texture = tags.get(eumling.type_secondary)
	%Taglines/Tagline3.texture = tags.get(eumling.type_tertiary)
