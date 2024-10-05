class_name BlenderEnemySkin
extends Node3D

@onready var animation_player: AnimationPlayer = %AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	set_quaternion(get_quaternion() * animation_player.get_root_motion_rotation())
