@tool
extends CharacterBody3D

const MOUSE_MOTION_SCALE_DOWN_FACTOR: float = 1500

@export var mouse_sensitivity: float = 0.25

@export var move_max_speed: float = 5
@export var move_jump_impulse: float = 10

@export var movement_processor: MovementProcessor = null

@onready var camera_pivot: Node3D = %CameraPivot
@onready var weapon_animation_tree: AnimationTree = %WeaponAnimationTree


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_process_movement(delta)

func _input(event: InputEvent):
	if Engine.is_editor_hint():
		return
	# TODO : Mouse capture does not belong in player code
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			get_viewport().set_input_as_handled()
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_process_mouse_motion(event.screen_relative)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack_1"):
		_attack()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if movement_processor == null:
		warnings.append("%s has no movement_processor !" % name)
	return warnings

## Move the player according to input
func _process_movement(delta: float) -> void:
	if movement_processor:
		movement_processor.process_movement(self, delta, move_max_speed, move_jump_impulse)

## Rotate the camera and the player based on mouse motion
func _process_mouse_motion(motion: Vector2) -> void:
	var scaled_motion = motion * (1.0 / MOUSE_MOTION_SCALE_DOWN_FACTOR)
	rotate_y(-scaled_motion.x * mouse_sensitivity)
	camera_pivot.rotate_x(-scaled_motion.y * mouse_sensitivity)

	var camera_rot = camera_pivot.rotation_degrees
	camera_rot.x = clamp(camera_rot.x, -90, 90)
	camera_pivot.rotation_degrees = camera_rot

func _attack():
	weapon_animation_tree["parameters/ThrustAttack/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	weapon_animation_tree.advance(100)
