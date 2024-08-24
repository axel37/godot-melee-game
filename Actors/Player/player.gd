extends CharacterBody3D

const MOUSE_MOTION_SCALE_DOWN_FACTOR: float = 1500

@export var mouse_sensitivity: float = 0.25


@export var move_max_speed: float = 5
@export var move_jump_impulse: float = 10

@export var movement_processor: MovementProcessor = null

@onready var camera_pivot: Node3D = %CameraPivot

func _physics_process(delta: float) -> void:
	process_movement(delta)


func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		print("Releasing mouse...")
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		print("Capturing mouse...")
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var scaled_motion = event.screen_relative * (1.0 / MOUSE_MOTION_SCALE_DOWN_FACTOR)
		rotate_y(-scaled_motion.x * mouse_sensitivity)
		camera_pivot.rotate_x(-scaled_motion.y * mouse_sensitivity)

		var camera_rot = camera_pivot.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -90, 90)
		camera_pivot.rotation_degrees = camera_rot



func process_movement(delta: float) -> void:
	if movement_processor:
		movement_processor.process_movement(self, delta, move_max_speed, move_jump_impulse)
	else:
		print("No movement processor assigned to Player node.")
