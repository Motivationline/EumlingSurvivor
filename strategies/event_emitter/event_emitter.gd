@abstract
class_name EventEmitter extends Node

@export var listeners: Array[EventStrategy]

signal event_triggered

func _ready() -> void:
	Strategy._setup_array(listeners, owner, owner)

func _trigger(data) -> void:
	for ev in listeners:
		if ev:
			ev.event_triggered(data)
	event_triggered.emit()
