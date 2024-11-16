class_name StandardMovementProcessor
extends MovementProcessor

## The speed at which the player should stop accelerating (grounded, in a straight line)
@export var move_max_speed: float = 5
## The vertical velocity to add upon jumping
@export var move_jump_impulse: float = 10

func compute_next_velocity(character: Player, delta: float) -> Vector3:
	var next_velocity: Vector3 = character.velocity

	# Add the gravity.
	if not character.is_on_floor():
		next_velocity += character.get_gravity() * delta

	if not character.ignore_movement_input:
		# Handle jump.
		if Input.is_action_just_pressed("move_jump") and character.is_on_floor():
			next_velocity.y = move_jump_impulse

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir := Input.get_vector("move_left", "move_right", "move_front", "move_back")
		var direction := (character.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			next_velocity.x = direction.x * move_max_speed
			next_velocity.z = direction.z * move_max_speed
		else:
			next_velocity = _friction(next_velocity, 0.86)
	else:
		next_velocity = _friction(next_velocity, 0.88)

	return next_velocity

func _friction(current_velocity: Vector3, factor: float) -> Vector3:
	var next_velocity: Vector3 = current_velocity
	next_velocity.x *= factor
	next_velocity.z *= factor
	return next_velocity
