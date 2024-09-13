@icon("res://Assets/Class icons/damage-dealing-handler.svg")
class_name DamageDealingHandler
extends Node3D

signal was_blocked

## The [DamageDealer]s to be handled by this node.
## Set automatically on _ready by default. See [member auto_register_children].
@export var damage_dealers: Array[DamageDealer] = []
## Whether all [DamageReceiver] child nodes should be registered on _ready.
## Setting this to false allows you to manually pick them in [member damage_receivers].
@export var auto_register_children = true

func _ready() -> void:
	if auto_register_children:
		_register_children()

	# Connect to signals of owned damage_receivers
	for dealer in damage_dealers:
		dealer.was_blocked.connect(_on_dealer_was_blocked)

# TODO : Duplicate logic with receiving_handler !
## Register all [DamageDealer] child nodes
func _register_children():
	for child in get_children():
			if child is DamageDealer:
				damage_dealers.append(child)

func _on_dealer_was_blocked():
	was_blocked.emit()
