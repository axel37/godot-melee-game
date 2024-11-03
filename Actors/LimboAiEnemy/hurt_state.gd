
extends LimboState

@export var animation_player: AnimationPlayer
@export var animation_name: StringName

func _enter() -> void:
	## TODO : State isn't called before it's over (= new hurt animation won't play before previous is over)
	## TODO : Enemy gets hurt once even if the player isn't attacking
	animation_player.stop()
	animation_player.play(animation_name, 1)


func _update(_delta: float) -> void:
	if not animation_player.is_playing() \
			or animation_player.assigned_animation != animation_name:
		dispatch(EVENT_FINISHED)
