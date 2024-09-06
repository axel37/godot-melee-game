@icon("res://Assets/Class icons/damage-receiver.svg")
## Area3D that can receive damage from [DamageDealer]
## Best used as a child of [DamageReceivingHandler]
class_name DamageReceiver
extends Area3D

const LOG_CODE_DAMAGE_RECEIVED = "DAMAGE-002"


signal detected_damage(damage_dealer: DamageDealer)

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area3D) -> void:
	if area is DamageDealer:
		var damage_dealer: DamageDealer = area as DamageDealer
		Global.log(LOG_CODE_DAMAGE_RECEIVED, "%s received damage from %s" % [name, damage_dealer.name])
		detected_damage.emit(damage_dealer)
