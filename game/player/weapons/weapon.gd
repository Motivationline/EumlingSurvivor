@abstract
extends Node3D

class_name Weapon

var base_type: Enum.EUMLING_TYPE

var possible_upgrades: Array[Upgrade]
var possible_playstyle_upgrades: Array[Enum.EUMLING_TYPE]
var current_playstyle_upgrades: Array[Enum.EUMLING_TYPE] = []

var player: Player

func setup(_player: Player):
	player = _player
	player.upgrade_added.connect(upgrade_added)

@abstract
func get_playstyle_upgrades() -> Array[Enum.EUMLING_TYPE]
@abstract
func get_possible_upgrades() -> Array[Upgrade]
@abstract
func physics_process(delta: float) -> void
@abstract
func process(delta: float) -> void
@abstract
func upgrade_added(_upgrade: Upgrade) -> void