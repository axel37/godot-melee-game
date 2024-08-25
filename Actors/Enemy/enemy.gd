extends Node3D

func _on_damage_receiver_received_damage(amount: float) -> void:
	print("%s received %f damage." % name, amount)
