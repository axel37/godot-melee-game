@icon("res://Assets/Class icons/damage-receiver.svg")
## Area3D that can receive damage from [DamageDealer]
class_name DamageReceiver
extends Area3D

signal received_damage(amount: float)

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area3D) -> void:
	if area is DamageDealer:
		var damage_dealer: DamageDealer = area as DamageDealer
		print("%s received damage from %s" % [name, damage_dealer.name])
		received_damage.emit(damage_dealer.amount)
