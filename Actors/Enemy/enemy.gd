extends Node3D

const LOG_CODE_DAMAGE_RECEIVED = "ENEMY-001"
const LOG_CODE_DAMAGE_BLOCKED = "ENEMY-002"



@onready var animation_tree: AnimationTree = %AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]
@onready var body_skin: Node3D = %BodySkin


func _on_damage_receiving_handler_received_damage() -> void:
	body_skin.play_hurt_animation()
	Global.log(LOG_CODE_DAMAGE_RECEIVED, "%s received damage." % [name])


func _on_enemy_damage_receiving_handler_blocked_damage() -> void:
	Global.log(LOG_CODE_DAMAGE_BLOCKED, "%s blocked damage." % [name])
	state_machine.travel("blocked")
