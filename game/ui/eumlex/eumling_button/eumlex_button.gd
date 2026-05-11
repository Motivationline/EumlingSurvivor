class_name EumlingButton extends TextureButton

var eumling: Eumling : 
	set(e):
		eumling = e
		update_visuals()
const GRAYSCALE_MATERIAL = preload("uid://bh8hp6lg5oyi8")


func update_visuals():
	$EumlingIcon.texture = eumling.image
	match eumling.progress:
		Enum.EUMLING_UNLOCK_PROGRESS.LOCKED:
			$MissingDisplay.show()
			$NewMarker.hide()
			$EumlingIcon.material = GRAYSCALE_MATERIAL
		Enum.EUMLING_UNLOCK_PROGRESS.UNLOCKED:
			$MissingDisplay.hide()
			$NewMarker.show()
			$EumlingIcon.material = null
		_:
			$MissingDisplay.hide()
			$NewMarker.hide()
			$EumlingIcon.material = null
