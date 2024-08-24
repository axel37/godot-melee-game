class_name StandardMovementProcessor
extends MovementProcessor

func process_movement(character: CharacterBody3D, delta: float, move_max_speed: float, move_jump_impulse: float) -> void:
	# Add the gravity.
		if not character.is_on_floor():
			character.velocity += character.get_gravity() * delta

		# Handle jump.
		if Input.is_action_just_pressed("move_jump") and character.is_on_floor():
			character.velocity.y = move_jump_impulse

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir := Input.get_vector("move_left", "move_right", "move_front", "move_back")
		var direction := (character.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			character.velocity.x = direction.x * move_max_speed
			character.velocity.z = direction.z * move_max_speed
		else:
			character.velocity.x = move_toward(character.velocity.x, 0, move_max_speed)
			character.velocity.z = move_toward(character.velocity.z, 0, move_max_speed)

		character.move_and_slide()
