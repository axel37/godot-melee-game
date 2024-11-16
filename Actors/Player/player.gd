@tool
## Main playable character code.
class_name Player
extends CharacterBody3D

const LOG_CODE_BLOCKED_INCOMING_DAMAGE = "PLAYER-001"
const LOG_CODE_TOOK_DAMAGE = "PLAYER-002"
const LOG_CODE_DIED = "PLAYER-003"


## Used to scale down mouse motion so that [member sensitivity] can match quake / source engine values.
## TODO : Approximate, find an exact value !
const MOUSE_MOTION_SCALE_DOWN_FACTOR: float = 1750

## Lower values means slower camera rotation.
## Should approximately match quake / source engine games.
@export var mouse_sensitivity: float = 0.25

## The speed at which the player should stop accelerating (grounded, in a straight line)
@export var move_max_speed: float = 5
## The vertical velocity to add upon jumping
@export var move_jump_impulse: float = 10
## Used to tuck away movement code from main player script.
## Designed to be replaceable.
@export var movement_processor: MovementProcessor = null

@export var health: int = 5

## Used for "vertical" camera rotation (looking up/down)
@onready var camera_pivot: Node3D = %CameraPivot
## [AnimationTree] managing animations for the viewmodel.
@onready var weapon_animation_tree: AnimationTree = %WeaponAnimationTree
## [member weapon_animation_tree]'s state machine.
@onready var state_machine: AnimationNodeStateMachinePlayback = weapon_animation_tree["parameters/Attack1StateMachine/playback"]

## Toggled by animations to disable movement.
@export var ignore_movement_input: bool = false
## Toggled by animations to disable player rotation
@export var _can_rotate: bool = true

@onready var hurt_particles: GPUParticles3D = %HurtParticles


var dead: bool = false

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if dead: return
	_process_movement(delta)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	if dead: return
	_update_animation_tree_inputs()

func _unhandled_input(event: InputEvent):
	if Engine.is_editor_hint(): return
	if dead: return
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
# TODO : Should that be handled by a movement_processor ?
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
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED: return

	weapon_animation_tree["parameters/Attack1StateMachine/conditions/is_attacking"] = Input.is_action_pressed("attack_1")
	weapon_animation_tree["parameters/Attack1StateMachine/conditions/is_attacking_thrust"] = Input.is_action_pressed("attack_2")
	weapon_animation_tree["parameters/Attack1StateMachine/conditions/is_guarding"] = Input.is_action_pressed("guard")

## [DamageDealingHandler] signaled an attack as being blocked.
func _on_damage_dealing_handler_was_blocked() -> void:
	state_machine.travel("attack_blocked")


func _on_damage_receiving_handler_blocked_damage() -> void:
	state_machine.travel("guarded")
	Global.log(LOG_CODE_BLOCKED_INCOMING_DAMAGE, "%s has guarded against an incoming attack." % name)


func _on_damage_receiving_handler_received_damage() -> void:
	Global.log(LOG_CODE_TOOK_DAMAGE, "%s took damage." % name)
	var particles_instance: GPUParticles3D = hurt_particles.duplicate()
	particles_instance.global_transform = hurt_particles.global_transform
	get_parent().add_child(particles_instance)
	particles_instance.emitting = true
	health -= 1
	if health <= 0:
		die()

func die():
	dead = true
	# Reset camera pivot to not break death animation
	camera_pivot.rotation = Vector3.ZERO
	state_machine.travel("death")
	Global.log(LOG_CODE_DIED, "%s died." % name)
