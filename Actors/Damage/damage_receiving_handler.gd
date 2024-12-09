## Handles receiving damage using a group of [DamageReceiver]
@icon("res://Assets/Class icons/damage_receiving_handler.svg")
class_name DamageReceivingHandler
extends Node3D

const LOG_CODE_DAMAGE_ALREADY_RECEIVED = "DAMAGE-RECEIVING-HANDLER-001"
const LOG_CODE_DAMAGE_BLOCKED = "DAMAGE-RECEIVING-HANDLER-002"

# TODO : What info should this signal transmit ?
signal received_damage
signal blocked_damage

## Scene to spawn when an attack has been blocked. Should probably be some particles, but any scene should work.
@export var block_particles: PackedScene = preload("res://Actors/Damage/block_particles.tscn")

# NOTICE DamageIds may be queue_freed by DamageDealers when they _renew themselves !
# WARNING This array fills up with nulls !
var _damage_sources_already_dealt_with: Array[DamageId] = []

var damage_receivers: NodeRegistry
var damage_blockers: NodeRegistry

## HACK : This stores the result of find_parent("*Level*") (it's a slow operation)
static var level: Node3D

func _ready() -> void:
	_register_children()

## Check if damage source if valid, then signal owner we have received damage
func _on_receiver_detected_damage(damage_dealer: DamageDealer):
	if _should_ignore(damage_dealer): return

	_damage_sources_already_dealt_with.append(damage_dealer.id)
	received_damage.emit()

## Block attack and spawn block VFX
func _on_blocker_detected_damage(_time_spent_blocking: float, damage_dealer: DamageDealer, dealer_shape_index: int, damage_blocker: DamageBlocker, blocker_area_index: int):
	if _should_ignore(damage_dealer): return

	_damage_sources_already_dealt_with.append(damage_dealer.id)
	damage_dealer.block()
	Global.log(LOG_CODE_DAMAGE_BLOCKED, "%s blocked dealer %s" % [name, damage_dealer.name])
	blocked_damage.emit()

	_spawn_block_particles(damage_dealer, dealer_shape_index, damage_blocker, blocker_area_index)

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


## Spawn VFX at the mid-point between the damage dealer and the damage blocker
## This is a good approximation for the actual collision point !
func _spawn_block_particles(damage_dealer: Area3D, dealer_shape_index: int, damage_blocker: DamageBlocker, blocker_shape_index: int) -> void:
	var damage_shape: CollisionShape3D = damage_dealer.shape_owner_get_owner(damage_dealer.shape_find_owner(dealer_shape_index))
	var blocker_shape: CollisionShape3D = damage_blocker.shape_owner_get_owner(damage_blocker.shape_find_owner(blocker_shape_index))

	var blocker_shape_position = blocker_shape.global_position

	var shape_pos: Vector3 = damage_shape.global_position
	var sub: Vector3 = blocker_shape_position - shape_pos
	var mid: Vector3 = sub * 0.5
	var final: Vector3 = shape_pos + mid

	var particle_node: Node3D = block_particles.instantiate()
	Global.level_manager.reparent_to_level(particle_node)
	particle_node.global_position = final
	particle_node.position = final
