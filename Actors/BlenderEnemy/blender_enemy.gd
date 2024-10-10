extends CharacterBody3D

const LOG_CODE_TOOK_DAMAGE = "BLENDER-ENEMY-01"

@onready var animation_tree: AnimationTree = %AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]

@onready var target_detector: Area3D = %TargetDetector

@export var health: int = 5
var dead: bool = false

var target: Node3D

func _physics_process(delta: float) -> void:
	# We're gonna need better than this
	if dead: return
	if target_detector.has_overlapping_bodies() && state_machine.get_current_node() == "idle":
		if target != null:
			look_at(Vector3(target.position.x, position.y, target.position.z))
		state_machine.travel("attack")


func _on_damage_receiving_handler_received_damage() -> void:
	Global.log(LOG_CODE_TOOK_DAMAGE, "%s took damage." % name)
	state_machine.travel("hurt")
	health -= 1
	if health <= 0:
		die()

func die():
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


func _on_target_detector_body_entered(body: Node3D) -> void:
	target = body
	state_machine.travel("attack")


func _on_hazard_detector_received_damage() -> void:
	state_machine.travel("guard")
