class_name Eumling extends Resource


@export var id: String

@export_category("Type Info")
@export var type: Enum.EUMLING_TYPE
@export var type_secondary: Enum.EUMLING_TYPE
@export var type_tertiary: Enum.EUMLING_TYPE

@export_category("Visuals")
@export var name: String
@export_multiline var info: String
@export var image: Texture


var progress: Enum.EUMLING_UNLOCK_PROGRESS = Enum.EUMLING_UNLOCK_PROGRESS.LOCKED