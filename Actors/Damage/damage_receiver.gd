@icon("res://Assets/Class icons/damage_receiver.svg")
class_name DamageReceiver
extends Area3D

signal received_damage(amount: float)


func _on_area_entered(area: Area3D) -> void:
	print("%s - onareaentered with : %s" % [name, area.name])
	if area is DamageDealer:
		var damage_dealer: DamageDealer = area as DamageDealer
		received_damage.emit(damage_dealer.amount)
