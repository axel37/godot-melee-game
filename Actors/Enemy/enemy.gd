@tool
## A target dummy (for now...)
extends Node3D

const LOG_CODE_DAMAGE_RECEIVED = "ENEMY-001"
const LOG_CODE_DAMAGE_BLOCKED = "ENEMY-002"
const LOG_CODE_DAMAGE_WAS_BLOCKED = "ENEMY-003"


## A Node3D with the enemy's appearance.
# Used for decoupling visuals from behaviour.
@export var skin_scene: PackedScene

## Whether to automatically play the attack animation in a loop
# One day, it'll be real AI !
@export var is_attacking: bool = false

@onready var animation_tree: AnimationTree = %AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]
## The instanciated  [member skin_scene]
var body_skin: Node3D

func _ready() -> void:
	if skin_scene != null:
		body_skin = skin_scene.instantiate()
		add_child(body_skin)

	animation_tree["parameters/conditions/is_attacking"] = is_attacking

## The enemy's [DamageReceivingHandler] has signaled that it should take damage.
func _on_damage_receiving_handler_received_damage() -> void:
	# TODO : bit of a hack, we can strengthen the type later...
	if body_skin.has_method("play_hurt_animation"):
		body_skin.play_hurt_animation()
	Global.log(LOG_CODE_DAMAGE_RECEIVED, "%s received damage." % [name])

## The enemy's [DamageReceivingHandler] has signaled that it has blocked incoming damage.
func _on_enemy_damage_receiving_handler_blocked_damage() -> void:
	Global.log(LOG_CODE_DAMAGE_BLOCKED, "%s blocked damage." % [name])
	state_machine.travel("blocked")

## Warn about incorrect configuration.
func _get_configuration_warnings() -> PackedStringArray:
	var errors = [];
	if skin_scene == null:
		errors.append("%s has no skin_scene" % name)
	return errors


func _on_enemy_damage_dealing_handler_was_blocked() -> void:
	Global.log(LOG_CODE_DAMAGE_WAS_BLOCKED, "%s was blocked" % name)
	state_machine.travel("was_blocked")
