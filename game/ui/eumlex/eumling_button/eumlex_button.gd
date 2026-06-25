class_name EumlingButton extends TextureButton

var eumling: Eumling : 
	set(e):
		eumling = e
		update_visuals()


func update_visuals():
	%EumlingIcon.texture = eumling.image
	match eumling.progress:
		Enum.EUMLING_UNLOCK_PROGRESS.LOCKED:
			$NewMarker.hide()
			$MissingOverlay.show()
		Enum.EUMLING_UNLOCK_PROGRESS.UNLOCKED:
			$MissingOverlay.show()
			$NewMarker.show()
		_:
			$MissingOverlay.hide()
			$NewMarker.hide()
