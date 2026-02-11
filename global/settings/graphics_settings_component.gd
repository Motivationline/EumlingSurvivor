@abstract
class_name GraphicsSettingsComponent extends Node

func _ready():
	GraphicsSettings.setting_changed.connect(on_setting_changed)
	var value = GraphicsSettings.get_setting(get_setting())
	apply(value)

func on_setting_changed(changed_setting, value):
	if changed_setting == get_setting():
		apply(value)
	
@abstract 
func apply(value)

@abstract
func get_setting() -> GraphicsSettings.SETTING

func toggle(value: bool):
	var parent := get_parent()
	if parent == null:
		return
		
	parent.visible = value
	parent.set_process(value)
	parent.set_physics_process(value)
