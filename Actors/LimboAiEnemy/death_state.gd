extends LimboState


@export var animation_player: AnimationPlayer
@export var animation_name: StringName

func _enter() -> void:
	animation_player.play(animation_name)
	animation_player.animation_finished.connect(_disable_processing)

func _disable_processing(_animation_name: String):
	agent.process_mode = Node.PROCESS_MODE_DISABLED
