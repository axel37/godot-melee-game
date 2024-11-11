# Guard from attacks
extends LimboState

@export var animation_player: AnimationPlayer
@export var animation_name: StringName
@export var damage_blocker: DamageBlocker

@export var duration_min: float = 1
@export var duration_max: float = 2.5


var remaining_duration_in_seconds: float = 0

func _enter() -> void:
	animation_player.play(animation_name)
	damage_blocker.enabled = true
	remaining_duration_in_seconds = randf_range(duration_min, duration_max)

func _update(delta: float) -> void:
	if remaining_duration_in_seconds <= 0:
		dispatch(EVENT_FINISHED)
	else:
		remaining_duration_in_seconds -= delta

func _exit() -> void:
	## TODO : Go back to idle animation
	# Not sure if we should do that here or in the "next" state
	damage_blocker.enabled = false
