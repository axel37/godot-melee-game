@tool
extends CharacterBody3D

const LOG_CODE_TOOK_DAMAGE = "AI-ENEMY-01"

@onready var skin_handler: SkinHandler = %SkinHandler
@onready var animation_tree: AnimationTree = %AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]

var skin: Node3D

func _ready() -> void:
	skin = skin_handler.get_skin()
	add_child(skin)


func _on_damage_receiving_handler_received_damage() -> void:
	Global.log(LOG_CODE_TOOK_DAMAGE, "%s took damage." % name)


func _on_target_detector_body_entered(_body: Node3D) -> void:
	skin.attack()
	state_machine.travel("attack")


func _on_hazard_detector_received_damage() -> void:
	skin.guard()
	state_machine.travel("guard")
