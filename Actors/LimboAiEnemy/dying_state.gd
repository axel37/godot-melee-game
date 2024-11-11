extends LimboState


@export var animation_player: AnimationPlayer
@export var animation_name: StringName

@onready var physics_shape: CollisionShape3D = %PhysicsShape

func _enter() -> void:
	animation_player.play(animation_name)
	physics_shape.set_deferred(&"disabled", true)
