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
## wishdir is our horizontal input, with a max length of 1.0
func _get_wishdir_from_input(_character: Node3D) -> Vector3:
	var horizontal_input: Vector2 = Input.get_vector(action_name_move_left, action_name_move_right, action_name_move_forward, action_name_move_back)
	return Vector3(horizontal_input.x, 0, horizontal_input.y).limit_length(1.0).rotated(Vector3.UP, _character.global_rotation.y)
