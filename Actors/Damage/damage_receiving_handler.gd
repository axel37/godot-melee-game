## Handles receiving damage using a group of [DamageReceiver]
@icon("res://Assets/Class icons/damage_receiving_handler.svg")
class_name DamageReceivingHandler
extends Node3D

const LOG_CODE_DAMAGE_ALREADY_RECEIVED = "DAMAGE-RECEIVING-HANDLER-001"
const LOG_CODE_DAMAGE_BLOCKED = "DAMAGE-RECEIVING-HANDLER-002"

# TODO : What info should this signal transmit ?
signal received_damage
signal blocked_damage

# NOTICE DamageIds may be queue_freed by DamageDealers when they _renew themselves !
# WARNING This array fills up with nulls !
var _damage_sources_already_dealt_with: Array[DamageId] = []

var damage_receivers: NodeRegistry
var damage_blockers: NodeRegistry

func _ready() -> void:
	_register_children()

## Check if damage source if valid, then signal owner we have received damage
func _on_receiver_detected_damage(damage_dealer: DamageDealer):
	if _should_ignore(damage_dealer): return

	_damage_sources_already_dealt_with.append(damage_dealer.id)
	received_damage.emit()

func _on_blocker_detected_damage(_time_spent_blocking: float, damage_dealer: DamageDealer):
	if _should_ignore(damage_dealer): return

	_damage_sources_already_dealt_with.append(damage_dealer.id)
	damage_dealer.block()
	Global.log(LOG_CODE_DAMAGE_BLOCKED, "%s blocked dealer %s" % [name, damage_dealer.name])
	blocked_damage.emit()

func _should_ignore(damage_dealer: DamageDealer) -> bool:
	if damage_dealer.id in _damage_sources_already_dealt_with:
		Global.log(LOG_CODE_DAMAGE_ALREADY_RECEIVED, "%s was hit by damage source %s, but was already registered. Ignoring..." % [name, damage_dealer.name])
		return true
	return false

## Register [DamageReceiver] and [DamageBlocker] child nodes and connect to their signals
func _register_children():
	damage_receivers = NodeRegistry.new(DamageReceiver)
	add_child(damage_receivers)
	damage_receivers.connect_signal("detected_damage", _on_receiver_detected_damage)

	damage_blockers = NodeRegistry.new(DamageBlocker)
	add_child(damage_blockers)
	damage_blockers.connect_signal("blocked_damage", _on_blocker_detected_damage)
