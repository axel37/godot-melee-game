extends Node3D

const LOG_CODE_DAMAGE_RECEIVED = "ENEMY-001"
const LOG_CODE_DAMAGE_BLOCKED = "ENEMY-002"


@onready var weapon_animation_player: AnimationPlayer = %WeaponAnimationPlayer
@onready var hurt_animation_player: AnimationPlayer = %HurtAnimationPlayer
@onready var animation_tree: AnimationTree = %AnimationTree


func _process(delta: float) -> void:
	animation_tree["parameters/conditions/blocked_damage"] = false


func _on_damage_receiving_handler_received_damage() -> void:
	hurt_animation_player.play("got_hurt")
	Global.log(LOG_CODE_DAMAGE_RECEIVED, "%s received damage." % [name])


func _on_enemy_damage_receiving_handler_blocked_damage() -> void:
	Global.log(LOG_CODE_DAMAGE_BLOCKED, "%s blocked damage." % [name])
	animation_tree["parameters/conditions/blocked_damage"] = true
	weapon_animation_player.play("blocked_damage")
