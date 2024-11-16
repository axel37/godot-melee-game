## Script emulating Quake / Source-style movement
class_name QuakeMovementProcessor
extends MovementProcessor

@export_group("Action names", "action_name")
@export var action_name_move_forward: String = "move_front"
@export var action_name_move_back: String = "move_back"
@export var action_name_move_left: String = "move_left"
@export var action_name_move_right: String = "move_right"

@export_group("Movement parameters")
## (Theoretical) Acceleration, in meters / second
@export var accel: float = 60.0
## (Theoretical) Maximum speed (at which we stop accelerating), in meters / second
@export var max_speed: float = 6.0
## (Theoretical) Maximum speed allowed while in the air, in meters / second.
## Note that it is very different from the actual maximum air speed, and is only used to skew calculations
@export var max_air_speed: float = 0.6
## Stop adding gravity when reached
@export var terminal_velocity: float = -5
## Friction applied to ground movement. In quake-based games, usually between 1 and 5
@export var friction: float = 5

## Whether the jump button can be held to continuously jump
@export var auto_jump: bool = false

@export_group("Debug options", "debug")
@export var debug_draw_wishdir: bool = true
@export var debug_wishdir_color: Color = Color.GREEN_YELLOW

@export var debug_draw_next_velocity: bool = true
@export var debug_next_velocity_scale: float = 0.5
@export var debug_next_velocity_color_ground: Color = Color.BLUE_VIOLET
@export var debug_next_velocity_color_air: Color = Color.STEEL_BLUE


func compute_next_velocity(character: CharacterBody3D, delta: float, move_max_speed: float, move_jump_impulse: float) -> Vector3:
	# If on ground, move_ground else move_air
	# TODO : Debug draw vectors
	# TODO : Passing _character here feels weird ?
	## TODO : PREFER PURE FUNCTIONS
	# TODO : Turn wishdir into vector2 ?
	# TODO : Turn long param list into inner classes ?
	# TODO : Bring back the comments
	# TODO : Debug arrows are lagging behind ??
	# TODO : Jump
	## Step 1 : Get input. "wishdir" represents the input direction (back/front/left/right)
	var wishdir: Vector3 = _get_wishdir_from_input(character)
	if debug_draw_wishdir && wishdir.length_squared() > 0:
		_debug_draw_vector(character, wishdir, 1.0, debug_wishdir_color)
	var should_jump: bool = _should_jump()

	# It's easier to work on "movement" velocity and "jump/gravity" velocity separately
	# so we extract the vertical component of the current velocity inside current_vertical_velocity
	var current_velocity: Vector3 = character.velocity
	var current_vertical_velocity: float = character.velocity.y

	if character.is_on_floor():
		if should_jump:
			should_jump = false
			current_vertical_velocity = move_jump_impulse
			# Mimic Quake's way of treating first frame after landing as still in the air
			var next_velocity: Vector3 = _move_air(current_velocity, current_vertical_velocity, wishdir, delta)
			## TODO : Only draw HORIZONTAL velocity
			if debug_draw_next_velocity:
				_debug_draw_vector(character, next_velocity, debug_next_velocity_scale, debug_next_velocity_color_ground)
			return next_velocity

		else:
			current_vertical_velocity = 0
			var next_velocity: Vector3 = _move_ground(current_velocity, current_vertical_velocity, wishdir, delta)
			## TODO : Only draw HORIZONTAL velocity
			if debug_draw_next_velocity:
				_debug_draw_vector(character, next_velocity, debug_next_velocity_scale, debug_next_velocity_color_ground)
			return next_velocity
	else:
		current_vertical_velocity = _gravity(current_vertical_velocity, character, delta)
		var next_velocity: Vector3 = _move_air(current_velocity, current_vertical_velocity, wishdir, delta)
		## TODO : Only draw HORIZONTAL velocity
		if debug_draw_next_velocity:
			_debug_draw_vector(character, next_velocity, debug_next_velocity_scale, debug_next_velocity_color_air)
		return next_velocity

## Check Input singleton for forward / strafe inputs
## wishdir is our horizontal input, with a max length of 1.0
func _get_wishdir_from_input(_character: Node3D) -> Vector3:
	var horizontal_input: Vector2 = Input.get_vector(action_name_move_left, action_name_move_right, action_name_move_forward, action_name_move_back)
	return Vector3(horizontal_input.x, 0, horizontal_input.y).limit_length(1.0).rotated(Vector3.UP, _character.global_rotation.y)


# Apply friction, then accelerate
func _move_ground(current_horizontal_velocity: Vector3, current_vertical_velocity: float, wishdir: Vector3, delta: float)-> Vector3:
	# We first work on the horizontal components of our current velocity
	var nextVelocity: Vector3 = Vector3.ZERO
	nextVelocity.x = current_horizontal_velocity.x
	nextVelocity.z = current_horizontal_velocity.z
	# Scale down velocity
	nextVelocity = _friction(nextVelocity, current_horizontal_velocity, delta)
	nextVelocity = _accelerate(wishdir, nextVelocity, accel, max_speed, delta)

	# Then get back our vertical component, and move the player
	nextVelocity.y = current_vertical_velocity
	return nextVelocity

# Accelerate without applying friction (with a lower allowed max_speed)
func _move_air(current_horizontal_velocity: Vector3, current_vertical_velocity: float, wishdir: Vector3, delta: float)-> Vector3:
	# We first work on only on the horizontal components of our current velocity
	var nextVelocity: Vector3 = Vector3.ZERO
	nextVelocity.x = current_horizontal_velocity.x
	nextVelocity.z = current_horizontal_velocity.z
	nextVelocity = _accelerate(wishdir, nextVelocity, accel, max_air_speed, delta)

	# Then get back our vertical component, and move the player
	nextVelocity.y = current_vertical_velocity
	return nextVelocity

func _friction(velocity: Vector3, input_velocity: Vector3, delta: float) -> Vector3:
	var speed: float = input_velocity.length()
	var scaled_velocity: Vector3

	# Check that speed isn't 0, this is to avoid divide by zero errors
	if speed != 0:
		var drop = speed * friction * delta # Amount of speed to be reduced by friction
		# ((max(speed - drop, 0) / speed) will return a number between 0 and 1, this is our speed multiplier from friction
		# The max() is there to avoid anything from happening in the case where the user sets friction to a negative value
		scaled_velocity = input_velocity * max(speed - drop, 0) / speed
	# Stop altogether if we're going too slow to notice
	if speed < 0.1:
		return Vector3.ZERO
	return scaled_velocity

# This is were we calculate the speed to add to current velocity
func _accelerate(wishdir: Vector3, input_velocity: Vector3, accel: float, max_speed: float, delta: float)-> Vector3:
	# Current speed is calculated by projecting our velocity onto wishdir.
	# We can thus manipulate our wishdir to trick the engine into thinking we're going slower than we actually are, allowing us to accelerate further.
	var current_speed: float = input_velocity.dot(wishdir)

	# Next, we calculate the speed to be added for the next frame.
	# If our current speed is low enough, we will add the max acceleration.
	# If we're going too fast, our acceleration will be reduced (until it evenutually hits 0, where we don't add any more speed).
	var add_speed: float = clamp(max_speed - current_speed, 0, accel * delta)

	return input_velocity + wishdir * add_speed

## Apply gravity, if terminal velocity hasn't yet been reached
# TODO : This only works if gravity points down / is incompatible with local gravity zones
func _gravity(current_vertical_velocity: float, character: CharacterBody3D, delta: float) -> float:
	if current_vertical_velocity <= terminal_velocity:
		return current_vertical_velocity
	return current_vertical_velocity + (character.get_gravity().y * delta)

## Draw a debug arrow corresponding to a vector
func _debug_draw_vector(character: CharacterBody3D, vector: Vector3, scale: float = 1.0, color: Color = Color.GRAY):
		DebugDraw3D.draw_arrow(character.global_position, character.global_position + (vector * scale), color, .25)

## If the character should jump when given the occasion
func _should_jump()-> bool:
	var should_jump: bool = false

	# If auto_jump is true, the player keeps jumping as long as the key is kept down
	if auto_jump:
		should_jump = true if Input.is_action_pressed("move_jump") else false
		return should_jump

	if Input.is_action_just_pressed("move_jump"):
		should_jump = true
	if Input.is_action_just_released("move_jump"):
		should_jump = false

	return should_jump
