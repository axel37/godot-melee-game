## Handles receiving damage using a group of [DamageReceiver]
@icon("res://Assets/Class icons/damage_receiving_handler.svg")
class_name DamageReceivingHandler
extends Node3D

const LOG_CODE_DAMAGE_ALREADY_RECEIVED = "DAMAGE-RECEIVING-HANDLER-001"
const LOG_CODE_DAMAGE_BLOCKED = "DAMAGE-RECEIVING-HANDLER-002"


# TODO : What info should this signal transmit ?
signal received_damage
signal blocked_damage

## The [DamageReceiver]s to be handled by this node.
## Set automatically on _ready by default. See [member auto_register_children].
@export var damage_receivers: Array[DamageReceiver] = []
## The [DamageBlocker]s to be handled by this node.
## Set automatically on _ready by default. See [member auto_register_children].
@export var damage_blockers: Array[DamageBlocker] = []
## Whether all [DamageReceiver] child nodes should be registered on _ready.
## Setting this to false allows you to manually pick them in [member damage_receivers].
@export var auto_register_children = true

# Warning : DamageIds may be queue_freed by DamageDealers when they _renew themselves !
# This array fills up with nulls !
var _damage_sources_already_dealt_with: Array[DamageId] = []

func _ready() -> void:
	if auto_register_children:
		_register_children()

	# Connect to signals of owned damage_receivers
	for receiver in damage_receivers:
		receiver.detected_damage.connect(_on_receiver_detected_damage)
	for blocker in damage_blockers:
		blocker.blocked_damage.connect(_on_blocker_detected_damage)

## Check if damage source if valid, then signal owner we have received damage
func _on_receiver_detected_damage(damage_dealer: DamageDealer):
	if _should_ignore(damage_dealer): return

	_damage_sources_already_dealt_with.append(damage_dealer.id)
	received_damage.emit()

func _on_blocker_detected_damage(time_spent_blocking: float, damage_dealer: DamageDealer):
	if _should_ignore(damage_dealer): return

	_damage_sources_already_dealt_with.append(damage_dealer.id)
	damage_dealer.block()
	Global.log(LOG_CODE_DAMAGE_BLOCKED, "%s blocked dealer %s" % [name, damage_dealer.name])
	blocked_damage.emit()

## Register all [DamageReceiver] and [DamageBlocker] child nodes
func _register_children():
	for child in get_children():
			if child is DamageReceiver:
				damage_receivers.append(child)
			if child is DamageBlocker:
				damage_blockers.append(child)

func _should_ignore(damage_dealer: DamageDealer) -> bool:
	if damage_dealer.id in _damage_sources_already_dealt_with:
		Global.log(LOG_CODE_DAMAGE_ALREADY_RECEIVED, "%s was hit by damage source %s, but was already registered. Ignoring..." % [name, damage_dealer.name])
		return true
	return false
