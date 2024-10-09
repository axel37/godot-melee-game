extends CharacterBody3D

const LOG_CODE_TOOK_DAMAGE = "BLENDER-ENEMY-01"

@onready var animation_tree: AnimationTree = %AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]




func _on_damage_receiving_handler_received_damage() -> void:
	Global.log(LOG_CODE_TOOK_DAMAGE, "%s took damage." % name)


func _on_target_detector_body_entered(body: Node3D) -> void:
	state_machine.travel("attack")


func _on_hazard_detector_received_damage() -> void:
	state_machine.travel("guard")
