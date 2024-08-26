extends Node3D

@onready var animation_player: AnimationPlayer = %AnimationPlayer

func _on_enemy_damage_receiver_received_damage(amount: float) -> void:
	animation_player.play("got_hurt")
	print("%s received %f damage." % [name, amount])
