@tool
extends EditorPlugin

const WindGizmoPlugin = preload("world_wind_gizmo_plugin.gd")

var gizmo = WindGizmoPlugin.new()

func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	add_node_3d_gizmo_plugin(gizmo)


func _exit_tree() -> void:
	remove_node_3d_gizmo_plugin(gizmo)
