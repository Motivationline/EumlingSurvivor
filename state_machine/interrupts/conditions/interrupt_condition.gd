@abstract
@tool
@icon("interrupt_condition.svg")
class_name InterruptCondition extends Node

var parent: StateMachinePoweredEntity

## Returns `true` if the interrupt condition is triggered, `false` otherwise.
@abstract
func evaluate() -> bool

func setup(_parent: StateMachinePoweredEntity):
	parent = _parent

func start():
	pass