extends Control

var tabContainer: TabContainer
enum TABS {GRAPHICS = 0, SOUND = 1}

func _ready() -> void:
	tabContainer = %SettingsTabContainer
	tabContainer.tab_changed.connect(on_tab_changed)

func _on_visibility_changed():
	if visible:
		%CloseButton.grab_focus()


func _unhandled_input(event):
	if visible:
		if event.is_action_pressed("cycle_ui_left") or event.is_action_pressed("cycle_ui_right"):
			if tabContainer.current_tab == TABS.GRAPHICS:
				tabContainer.current_tab = TABS.SOUND
			else:
				tabContainer.current_tab = TABS.GRAPHICS

func on_tab_changed(_tab: int) -> void:
	if _tab== TABS.SOUND:
		%CloseButton.focus_neighbor_left = %MusicSlider.get_path()
		%CloseButton.focus_neighbor_bottom = %MusicSlider.get_path()
		%MusicContainer.grab_focus()
		#print("Sound")
	else:
		%CloseButton.focus_neighbor_left = %GraphicsSettings.quality_preset_option.get_path()
		%CloseButton.focus_neighbor_bottom = %GraphicsSettings.quality_preset_option.get_path()
		%GraphicsSettings.quality_preset_option.grab_focus()
		#print("GRAPHICS")
