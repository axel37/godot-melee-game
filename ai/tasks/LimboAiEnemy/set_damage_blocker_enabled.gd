## Enable or disable a damage_blocker
extends BTAction

@export var value: bool
@export var damage_blocker: BBNode



func _tick(_delta: float) -> Status:
	var blocker: DamageBlocker = damage_blocker.get_value(scene_root, blackboard)

	blocker.enabled = value
	return SUCCESS
