## Script emulating Quake / Source-style movement
## Assumes gravity points down. This is not (yet ?) compatible with exotic gravity setups.
class_name QuakeMovementProcessor
extends MovementProcessor

@export_group("Action names", "action_name")
@export var action_name_move_forward: String = "move_front"
@export var action_name_move_back: String = "move_back"
@export var action_name_move_left: String = "move_left"
@export var action_name_move_right: String = "move_right"

@export_group("Movement parameters")
## (Theoretical) Acceleration, in meters / second
@export_range(0, 120, 5) var accel: float = 60.0
## (Theoretical) Maximum speed (at which we stop accelerating), in meters / second
@export_range(0, 12, .5) var max_speed: float = 6.0
## (Theoretical) Maximum speed allowed while in the air, in meters / second.
## Note that it is very different from the actual maximum air speed, and is only used to skew calculations
@export_range(0, 1.2, .05) var max_air_speed: float = 0.6
## Stop adding gravity when reached
@export_range(-10, 0, 0.5) var terminal_velocity: float = -5
## Friction applied to ground movement. In quake-based games, usually between 1 and 5
@export_range(0, 10, .5) var friction: float = 5
## Vertical velocity to be added upon a jump
@export_range(0, 10, .5) var jump_impulse: float = 5
## Whether the jump button can be held to continuously jump
@export var auto_jump: bool = true

@export_group("Debug options", "debug")
@export var debug_draw_wishdir: bool = true
@export var debug_wishdir_color: Color = Color.GREEN_YELLOW

@export var debug_draw_draw_accelerate: bool = true
@export var debug_draw_accelerate_scale: float = 0.5
@export var debug_draw_accelerate_color_ground: Color = Color.BLUE_VIOLET
@export var debug_draw_accelerate_color_air: Color = Color.STEEL_BLUE

## Compute a next velocity for character based on input (collected from Input singleton)
## character : Needs to be a CharacterBody3D (we need is_on_floor and get_gravity)
## delta : delta-time since last frame
## ignore input : whether movement/jump inputs should be ignored (which amounts to only applying friction / gravity)
func compute_next_velocity(character: CharacterBody3D, delta: float, ignore_input: bool = false) -> Vector3:
	# TODO : Passing _character here feels weird ?
	# TODO : Debug arrows are lagging behind ??
	# TODO : Jump queuing
	# TODO : Set vertical velocity to 0 on ceiling collision
	## Step 1 : Collect input. "wishdir" represents the input direction (back/front/left/right)
	var wishdir: Vector3 = Vector3.ZERO
	var should_jump: bool = false
	if not ignore_input:
		wishdir = _get_wishdir_from_input(character)
		should_jump = _should_jump()

	if Global.game_settings.debug_overlay_movement_enable_wishdir && wishdir.length_squared() > 0:
		_debug_draw_vector(character, wishdir, 1.0, debug_wishdir_color)

	# It's easier to work on "movement" (horizontal) velocity and "jump/gravity" (vertical) velocity separately
	# so we extract the vertical component of the current velocity inside current_vertical_velocity
	var current_velocity: Vector3 = character.velocity
	var current_vertical_velocity: float = character.velocity.y

	## Step 2 : Move character
	# If in air or jumping : move_air else : move_ground
	if not character.is_on_floor():
		current_vertical_velocity = _gravity(current_vertical_velocity, character, delta)
		return _move_air(current_velocity, current_vertical_velocity, wishdir, character, delta)
	elif should_jump:
		# Mimic Quake's way of treating first frame after landing as still in the air
		should_jump = false
		current_vertical_velocity = jump_impulse
		return _move_air(current_velocity, current_vertical_velocity, wishdir, character, delta)
	else:
		current_vertical_velocity = 0
		return _move_ground(current_velocity, current_vertical_velocity, wishdir, character, delta)



## Check Input singleton for forward / strafe inputs
## wishdir is our horizontal input, with a max length of 1.0
func _get_wishdir_from_input(_character: Node3D) -> Vector3:
	var horizontal_input: Vector2 = Input.get_vector(action_name_move_left, action_name_move_right, action_name_move_forward, action_name_move_back)
	return Vector3(horizontal_input.x, 0, horizontal_input.y).limit_length(1.0).rotated(Vector3.UP, _character.global_rotation.y)


## Apply friction, then accelerate
func _move_ground(current_horizontal_velocity: Vector3, current_vertical_velocity: float, wishdir: Vector3, character: Node3D, delta: float)-> Vector3:
	# We first work on the horizontal components of our current velocity
	var next_velocity: Vector3 = Vector3.ZERO
	next_velocity.x = current_horizontal_velocity.x
	next_velocity.z = current_horizontal_velocity.z
	# Scale down velocity
	next_velocity = _friction(next_velocity, current_horizontal_velocity, delta)
	next_velocity = _accelerate(wishdir, next_velocity, accel, max_speed, delta)

	if Global.game_settings.debug_overlay_movement_enable_accelerate:
		_debug_draw_vector(character, next_velocity, debug_draw_accelerate_scale, debug_draw_accelerate_color_ground)

	# Then get back our vertical component, and move the player
	next_velocity.y = current_vertical_velocity
	return next_velocity

## Accelerate without applying friction (with a lower allowed max_speed)
func _move_air(current_horizontal_velocity: Vector3, current_vertical_velocity: float, wishdir: Vector3, character: Node3D, delta: float)-> Vector3:
	# We first work on only on the horizontal components of our current velocity
	var next_velocity: Vector3 = Vector3.ZERO
	next_velocity.x = current_horizontal_velocity.x
	next_velocity.z = current_horizontal_velocity.z
	next_velocity = _accelerate(wishdir, next_velocity, accel, max_air_speed, delta)

	if Global.game_settings.debug_overlay_movement_enable_accelerate:
		_debug_draw_vector(character, next_velocity, debug_draw_accelerate_scale, debug_draw_accelerate_color_air)

	# Then get back our vertical component, and move the player
	next_velocity.y = current_vertical_velocity
	return next_velocity

## Scale down horizontal velocityl
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

	# TODO : Debug draw result

	return input_velocity + wishdir * add_speed

## Apply gravity, if terminal velocity hasn't yet been reached
# TODO : This only works if gravity points down / this is incompatible with local gravity zones
func _gravity(current_vertical_velocity: float, character: CharacterBody3D, delta: float) -> float:
	if current_vertical_velocity <= terminal_velocity:
		return current_vertical_velocity
	return current_vertical_velocity + (character.get_gravity().y * delta)

## Draw a debug arrow corresponding to a vector
func _debug_draw_vector(character: Node3D, vector: Vector3, scale: float = 1.0, color: Color = Color.GRAY):
	if not Global.game_settings.debug_overlay_movement_enable: return
	DebugDraw3D.draw_arrow(character.global_position, character.global_position + (vector * scale), color, .25)

## If the character should jump when given the occasion
# TODO : Jump queuing (queue jump for x seconds after pressing button)
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
