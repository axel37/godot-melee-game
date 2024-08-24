extends CharacterBody3D

@export var move_max_speed: float = 5
@export var move_jump_impulse: float = 10

@export var movement_processor: MovementProcessor = null

func _physics_process(delta: float) -> void:
	process_movement(delta)


func process_movement(delta: float) -> void:
	if movement_processor:
		movement_processor.process_movement(self, delta, move_max_speed, move_jump_impulse)
	else:
		print("No movement processor assigned to Player node.")
