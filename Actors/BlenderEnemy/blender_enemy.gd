extends CharacterBody3D

@onready var skin: BlenderEnemySkin = %skin


const SPEED = 5.0
const JUMP_VELOCITY = 4.5


func _physics_process(delta: float) -> void:
	# TODO : Match self rotation on the z axis with skin's rotation
	#rotation.y = skin.rotation.y
	#var velocity: Vector3 = (skin.animation_player.get_root_motion_rotation_accumulator().inverse() * get_quaternion()) * skin.animation_player.get_root_motion_position() / delta
	#if not is_on_floor():
	#	velocity += get_gravity()
	#set_velocity(velocity)
	#move_and_slide()
	pass
