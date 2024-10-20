extends CharacterBody3D

const LOG_CODE_TOOK_DAMAGE = "BLENDER-ENEMY-01"
const LOG_CODE_DIED = "BLENDER-ENEMY-02"


@onready var animation_tree: AnimationTree = %AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]
@onready var target_detector: Area3D = %TargetDetector
@onready var guard_timer: Timer = %GuardTimer

@export var health: int = 5
var dead: bool = false

var target: Node3D

func _physics_process(_delta: float) -> void:
	# We're gonna need better than this
	if dead: return
	if not state_machine.get_current_node() == "idle": return

	if target_detector.has_overlapping_bodies():
		_look_at_target_if_exists()
		# 1/4 chance of guarding immediately
		var choices = [guard, attack, attack, attack]
		choices.pick_random().call()



func _on_damage_receiving_handler_received_damage() -> void:
	# TODO : This is sometimes not shown
	state_machine.travel("hurt")
	health -= 1
	Global.log(LOG_CODE_TOOK_DAMAGE, "%s took damage." % name)
	if health <= 0:
		die()


func _on_target_detector_body_entered(body: Node3D) -> void:
	if not guard_timer.is_stopped(): return
	if not state_machine.get_current_node() == "idle": return
	target = body
	attack()


func _on_hazard_detector_received_damage() -> void:
	if not state_machine.get_current_node() == "idle": return
	guard()

func guard():
	state_machine.travel("guard")
	_look_at_target_if_exists()
	guard_timer.wait_time = randf_range(0.5,3)
	guard_timer.start()

func attack():
	_look_at_target_if_exists()
	state_machine.travel("attack")

func _on_guard_timer_timeout() -> void:
	if dead: return
	state_machine.travel("idle")

func _look_at_target_if_exists():
	if target != null:
		look_at(Vector3(target.position.x, position.y, target.position.z))

func die():
	# TODO : death anim somtimes plays late
	dead = true
	state_machine.travel("death")
	%PhysicsShape.set_deferred("disabled", true)
	%DamageDealer.set_deferred("enabled", false)
	target_detector.set_deferred("monitorable", false)
	target_detector.set_deferred("monitoring", false)
	%DamageReceiver.set_deferred("monitoring", false)
	%DamageReceiver.set_deferred("monitorable", false)
	$DamageReceivingHandler/DamageReceiver.set_deferred("monitorable", false)
	$DamageReceivingHandler/DamageReceiver.set_deferred("monitoring", false)
	%DamageBlocker.set_deferred("enabled", false)
	Global.log(LOG_CODE_TOOK_DAMAGE, "%s took damage." % name)
