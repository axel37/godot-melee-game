@tool
class_name Player
extends CharacterBody3D

const MOUSE_MOTION_SCALE_DOWN_FACTOR: float = 1750

@export var mouse_sensitivity: float = 0.25

@export var move_max_speed: float = 5
@export var move_jump_impulse: float = 10

@export var movement_processor: MovementProcessor = null

@onready var camera_pivot: Node3D = %CameraPivot
@onready var weapon_animation_tree: AnimationTree = %WeaponAnimationTree

## Toggled by animations to disable movement.
@export var ignore_movement_input: bool = false
## Toggled by animations to disabled attacking
@export var _can_attack: bool = true
## Toggled by animations to disable player rotation
@export var _can_rotate: bool = true

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_process_movement(delta)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_update_animation_tree_inputs()

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
		var x_multiplier: float = 1.0 if _can_rotate else 0.1
		_process_mouse_motion(event.screen_relative, x_multiplier, 1)

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
func _process_mouse_motion(motion: Vector2, x_multiplier: float, y_multiplier: float) -> void:
	var scaled_motion = motion * (1.0 / MOUSE_MOTION_SCALE_DOWN_FACTOR)
	rotate_y(-scaled_motion.x * mouse_sensitivity * x_multiplier)
	camera_pivot.rotate_x(-scaled_motion.y * mouse_sensitivity * y_multiplier)

	var camera_rot = camera_pivot.rotation_degrees
	camera_rot.x = clamp(camera_rot.x, -90, 90)
	camera_pivot.rotation_degrees = camera_rot


## Make the player move forward. Used by animations.
func _step_forward(amount: float):
	var local_forward = -transform.basis.z
	velocity += local_forward * amount

## Give animation trees their needed input
func _update_animation_tree_inputs():
	weapon_animation_tree["parameters/Attack1StateMachine/conditions/is_attacking"] = Input.is_action_pressed("attack_1")
	weapon_animation_tree["parameters/Attack1StateMachine/conditions/is_attacking_thrust"] = Input.is_action_pressed("attack_2")
