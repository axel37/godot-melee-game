# Plays a stagger animation, during which the enemy can't do anything
extends LimboState

@export var animation_player: AnimationPlayer
@export var animation_name: StringName

func _enter() -> void:
	animation_player.play(animation_name)


func _update(_delta: float) -> void:
	if not animation_player.is_playing() \
			or animation_player.assigned_animation != animation_name:
		dispatch(EVENT_FINISHED)
