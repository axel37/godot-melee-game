@icon("res://Assets/Class icons/damage-dealer.svg")
## Area3D used to deal damage to [DamageReceiver]
class_name DamageDealer
extends Area3D

const LOG_CODE_DAMAGE_DEALT = "DAMAGE-001"
const LOG_CODE_SET_ENABLED = "DAMAGE-002"


signal dealt_damage()

@export var amount: float = 0

@export var enabled: bool = true:
	set = _set_enabled

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area3D) -> void:
	if area is DamageReceiver:
		var damage_receiver: DamageReceiver = area as DamageReceiver
		Global.log(LOG_CODE_DAMAGE_DEALT, "%s dealt damage to %s" % [name, damage_receiver.name])
		dealt_damage.emit()

func _set_enabled(value: bool):
	if enabled == value:
		return  # TODO : Avoid redundant sets (this is being called every frame !)

	enabled = value
	monitorable = value
	monitoring = value
	Global.log(LOG_CODE_SET_ENABLED, "%s : _set_enabled %s" % [name, value])
