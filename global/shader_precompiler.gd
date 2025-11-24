extends Node3D

# Dictionary mapping PackedScene → instantiated Node (or null if already prewarmed)
var registry: Dictionary[PackedScene, Node]

# Prewarm a scene by instantiating it if it hasn’t been prewarmed yet.
func prewarm(_scene: PackedScene) -> void:
	if _scene in registry:
		return

	var instance = _scene.instantiate();
	registry[_scene] = instance
	add_child(instance)

# Release the instance of a prewarmed scene, leaving a null entry to mark it handled.
func release(_scene: PackedScene) -> void:
	var instance = registry.get(_scene);
	if !instance:
		return

	registry[_scene] = null;
	instance.queue_free();

# Release all active instances while preserving prewarm history.
func flush() -> void:
	for scene in registry.keys():
		release(scene)
