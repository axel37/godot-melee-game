## Area3D used to block/guard from [DamageDealer]s
## Best used as a child of [DamageReceivingHandler]
@icon("res://Assets/Class icons/damage-blocker.svg")
class_name DamageBlocker
extends Area3D

const LOG_CODE_SET_ENABLED = "BLOCKER-001"
const LOG_CODE_DAMAGE_BLOCKED = "BLOCKER-002"

signal blocked_damage(time_since_block: float, damage_dealer: DamageDealer)

@export var enabled: bool = true:
	set = _set_enabled

## Time this DamageBlocker has been active
var time_blocking: float = 0

func _ready() -> void:
	_renew()
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area3D) -> void:
	if area is DamageDealer:
		var damage_dealer: DamageDealer = area as DamageDealer
		Global.log(LOG_CODE_DAMAGE_BLOCKED, "%s blocked damage %s" % [name, damage_dealer.name])
		blocked_damage.emit(time_blocking, damage_dealer)

func _renew() -> void:
	time_blocking = 0

func _process(delta: float) -> void:
	time_blocking += delta

func _set_enabled(value: bool):
	if enabled == value:
		return  # TODO : Avoid redundant sets (this is being called every frame !)

	enabled = value
	set_deferred("monitorable", value)
	set_deferred("monitoring", value)
	Global.log(LOG_CODE_SET_ENABLED, "%s : _set_enabled %s" % [name, value])
