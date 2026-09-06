@tool
class_name BalancingErrorState
extends RefCounted

var has_error: bool = false
var _context: BalancingContext


func _init(context: BalancingContext) -> void:
	_context = context


func set_error(message: String) -> void:
	if has_error:
		return

	has_error = true

	var context_values: Array[String] = []
	if _context.entry_index != -1:
		context_values.append("Entry: %d" % _context.entry_index)
	if not _context.scene.is_empty():
		context_values.append("Scene: %s" % _context.scene)
	if _context.difficulty != -1:
		context_values.append("Difficulty: %d" % _context.difficulty)
	if not _context.target.is_empty():
		context_values.append("Target: %s" % _context.target)
	if not _context.attribute.is_empty():
		context_values.append("Attribute: %s" % _context.attribute)

	if context_values.is_empty():
		push_error("Balancing: %s." % message)
	else:
		push_error("Balancing: %s.\n%s." % [message, ", ".join(context_values)])
