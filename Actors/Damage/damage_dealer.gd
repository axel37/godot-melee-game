@icon("res://Assets/Class icons/damage-dealer.svg")
## Area3D used to deal damage to [DamageReceiver]
class_name DamageDealer
extends Area3D

signal dealt_damage()

@export var amount: float = 0

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area3D) -> void:
	if area is DamageReceiver:
		var damage_receiver: DamageReceiver = area as DamageReceiver
		print("%s dealt damage to %s" % [name, damage_receiver.name])
		dealt_damage.emit()
