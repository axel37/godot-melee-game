@tool
extends CharacterBody3D

const LOG_CODE_TOOK_DAMAGE = "AI-ENEMY-01"

@onready var skin_handler: SkinHandler = %SkinHandler

var skin: Node3D

func _ready() -> void:
	print("Loading skin...")
	skin = skin_handler.get_skin()
	print(skin)
	add_child(skin)


func _on_damage_receiving_handler_received_damage() -> void:
	Global.log(LOG_CODE_TOOK_DAMAGE, "%s took damage." % name)


func _on_target_detector_body_entered(body: Node3D) -> void:
	skin.attack()
