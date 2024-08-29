@icon("res://Assets/Class icons/damage-receiver.svg")
## Area3D that can receive damage from [DamageDealer]
class_name DamageReceiver
extends Area3D

const LOG_CODE_DAMAGE_RECEIVED = "DAMAGE-002"
const LOG_CODE_DAMAGE_ALREADY_RECEIVED = "DAMAGE-004"


signal received_damage(amount: float)

var _damage_already_received: Array = []

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area3D) -> void:
	if area is DamageDealer:
		var damage_dealer: DamageDealer = area as DamageDealer
		if _was_already_hit_by_dealer(damage_dealer):
			Global.log(LOG_CODE_DAMAGE_ALREADY_RECEIVED, "%s was hit by %s, but was already registered. Ignoring..." % [name, damage_dealer.name])
			return
		_damage_already_received.append([damage_dealer, damage_dealer.id])
		Global.log(LOG_CODE_DAMAGE_RECEIVED, "%s received damage from %s" % [name, damage_dealer.name])
		received_damage.emit(damage_dealer.amount)

func _was_already_hit_by_dealer(damage_dealer: DamageDealer):
	return [damage_dealer, damage_dealer.id] in _damage_already_received
