extends Node3D

const LOG_CODE_DAMAGE_RECEIVED = "ENEMY-001"

@onready var animation_player: AnimationPlayer = %AnimationPlayer


func _on_damage_receiving_handler_received_damage() -> void:
	animation_player.play("got_hurt")
	Global.log(LOG_CODE_DAMAGE_RECEIVED, "%s received damage." % [name])
