extends Node3D

@onready var animation_tree: AnimationTree = %AnimationTree


func play_hurt_animation() -> void:
	print("Playing enemy hurt animation...")
	animation_tree["parameters/OneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
