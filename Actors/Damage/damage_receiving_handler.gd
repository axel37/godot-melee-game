## Handles receiving damage from a group of [DamageReceiver]
@icon("res://Assets/Class icons/damage_receiving_handler.svg")
class_name DamageReceivingHandler
extends Node3D

const LOG_CODE_DAMAGE_ALREADY_RECEIVED = "DAMAGE-004"

# TODO : What info should this signal transmit ?
signal received_damage

## The [DamageReceiver]s to be handled by this node.
## Set automatically on _ready by default. See [member auto_register_children].
@export var damage_receivers: Array[DamageReceiver] = []
## Whether all [DamageReceiver] child nodes should be registered on _ready.
## Setting this to false allows you to manually pick them in [member damage_receivers].
@export var auto_register_children = true

var _damage_sources_already_detected: Array[DamageId] = []

func _ready() -> void:
	if auto_register_children:
		_register_children()

	# Connect to signals of owned damage_receivers
	for receiver in damage_receivers:
		receiver.detected_damage.connect(_on_receiver_received_damage)

## Signal owner that we have detected damage
func _on_receiver_received_damage(damage_dealer: DamageDealer):
	var damage_id: DamageId = damage_dealer.id

	if damage_id in _damage_sources_already_detected:
		Global.log(LOG_CODE_DAMAGE_ALREADY_RECEIVED, "%s was hit by damage source %s, but was already registered. Ignoring..." % [name, damage_dealer.name])
		return

	_damage_sources_already_detected.append(damage_id)
	received_damage.emit()

## Register all [DamageReceiver] child nodes
func _register_children():
	for child in get_children():
			if child is DamageReceiver:
				damage_receivers.append(child)
