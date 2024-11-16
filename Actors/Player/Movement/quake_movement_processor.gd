## Script emulating Quake / Source-style movement
class_name QuakeMovementProcessor
extends MovementProcessor

@export var action_name_move_forward: String = "move_front"
@export var action_name_move_back: String = "move_back"
@export var action_name_move_left: String = "move_left"
@export var action_name_move_right: String = "move_right"


@export var debug_wishdir_color: Color = Color.GREEN_YELLOW

func process_movement(_character: Player, _delta: float, _move_max_speed: float, _move_jump_impulse: float) -> void:
	# If on ground, move_ground else move_air
	# TODO : Debug draw vectors
	# TODO : Passing _character here feels weird ?
	var wishdir: Vector3 = _get_wishdir_from_input(_character)
	if wishdir.length_squared() > 0:
		DebugDraw3D.draw_arrow(_character.global_position, _character.global_position + wishdir, debug_wishdir_color, .25, true)

	pass

## Check Input singleton for forward / strafe inputs
## wishdir is our normalized horizontal input
func _get_wishdir_from_input(_character: Node3D) -> Vector3:
	## TODO : This doesn't work great with joysticks (intensity is always 1)
	var forward_input: float = Input.get_axis(action_name_move_forward, action_name_move_back)
	var strafe_input: float = Input.get_axis(action_name_move_left, action_name_move_right)
	return Vector3(strafe_input, 0, forward_input).normalized().rotated(Vector3.UP, _character.global_rotation.y)
	# return Vector3(strafe_input, 0, forward_input).rotated(Vector3.UP, _character.global_transform.basis.get_euler().y).normalized()
