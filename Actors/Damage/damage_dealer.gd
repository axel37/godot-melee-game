@icon("res://Assets/Class icons/damage-dealer.svg")
## Area3D used to deal damage to [DamageReceiver]
class_name DamageDealer
extends Area3D

const LOG_CODE_DAMAGE_DEALT = "DAMAGE-001"
const LOG_CODE_SET_ENABLED = "DAMAGE-005"
const LOG_CODE_RECEIVER_ALREADY_HIT = "DAMAGE-003"



signal dealt_damage()

@export var amount: float = 0
@export var enabled: bool = true:
	set = _set_enabled

## Used to differentiate attacks for reused DamageDealers
var id: DamageId
var _receivers_already_hit: Array[DamageReceiver] = []

func _ready() -> void:
	_renew()
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area3D) -> void:
	if area is DamageReceiver:
		var damage_receiver: DamageReceiver = area as DamageReceiver
		if _has_already_hit_receiver(damage_receiver):
			Global.log(LOG_CODE_RECEIVER_ALREADY_HIT, "%s hit %s, but was already registered. Ignoring..." % [name, area.name])
			return
		_receivers_already_hit.append(damage_receiver)
		Global.log(LOG_CODE_DAMAGE_DEALT, "%s dealt damage to %s" % [name, damage_receiver.name])
		dealt_damage.emit()

func _set_enabled(value: bool):
	if enabled == value:
		return  # TODO : Avoid redundant sets (this is being called every frame !)

	enabled = value
	monitorable = value
	monitoring = value
	Global.log(LOG_CODE_SET_ENABLED, "%s : _set_enabled %s" % [name, value])

## DamageReceivers will consider this to be a new attack, and will allow themselves to be hit again.
func _renew() -> void:
	id = DamageId.new()
	_receivers_already_hit =[]

func _has_already_hit_receiver(damage_receiver: DamageReceiver) -> bool:
	return damage_receiver in _receivers_already_hit
