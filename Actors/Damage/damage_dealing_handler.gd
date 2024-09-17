@icon("res://Assets/Class icons/damage-dealing-handler.svg")
class_name DamageDealingHandler
extends Node3D

signal was_blocked

var damage_dealers: NodeRegistry

func _ready() -> void:
	_register_children()

## Register [DamageDealer] child nodes and connect to their signals
func _register_children():
	damage_dealers = NodeRegistry.new(DamageDealer)
	add_child(damage_dealers)
	damage_dealers.connect_signal("was_blocked", _on_dealer_was_blocked)

func _on_dealer_was_blocked():
	was_blocked.emit()
