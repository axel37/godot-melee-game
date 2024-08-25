@icon("res://Assets/Class icons/damage_dealer.svg")
class_name DamageDealer
extends Area3D

signal dealt_damage()

var amount: float = 0

func _on_area_entered(area: Area3D) -> void:
	if area is DamageReceiver:
		var damage_receiver: DamageReceiver = area as DamageReceiver
		dealt_damage.emit()
