@icon("res://Assets/Class icons/damage-dealer.svg")
## Area3D used to deal damage to [DamageReceiver]
## It's only monitorable and does no monitoring by itself.
class_name DamageDealer
extends UniqueShapeArea3D

const LOG_CODE_DAMAGE_DEALT = "DAMAGE-001"
const LOG_CODE_SET_ENABLED = "DAMAGE-005"
const LOG_CODE_RECEIVER_ALREADY_HIT = "DAMAGE-003"
const LOG_CODE_WAS_BLOCKED = "DAMAGE-006"

signal was_blocked

@export var amount: float = 0
@export var enabled: bool = true:
	set = _set_enabled

## Used to differentiate attacks for reused DamageDealers
var id: DamageId

func _ready() -> void:
	# Needed to call UniqueShapeArea3D's make unique mechanism
	super._ready()
	monitoring = false
	_renew()

## Called by external entities who blocked this attack
func block() -> void:
	was_blocked.emit()
	Global.log(LOG_CODE_WAS_BLOCKED, "%s was blocked()" % name)

func _set_enabled(value: bool):
	if enabled == value:
		return  # TODO : Avoid redundant sets (this is being called every frame !)

	enabled = value
	monitorable = value
	Global.log(LOG_CODE_SET_ENABLED, "%s : _set_enabled %s" % [name, value])

## DamageReceivers will consider this to be a new attack, and will allow themselves to be hit again.
func _renew() -> void:
	# Prevent unused objects from hanging around
	if id != null:
		id.queue_free()
	id = DamageId.new()
