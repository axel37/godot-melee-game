## Enable or disable a damage_blocker
@tool
extends BTAction

@export var value: bool = false
@export var damage_blocker: BBNode

const LOG_CODE_NO_DAMAGE_BLOCKER = "TASK-SETDAMAGEBLOCKERENABLED-001"

func _generate_name() -> String:
	if value:
		return "Enable damage blocker"
	else:
		return "Disable damage blocker"

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if damage_blocker == null:
		warnings.append("damage_blocker must be set")
	return warnings

func _tick(_delta: float) -> Status:
	if damage_blocker == null:
		Global.log(LOG_CODE_NO_DAMAGE_BLOCKER, "damage_blocker was not set, failing")
		return FAILURE

	var blocker: DamageBlocker = damage_blocker.get_value(scene_root, blackboard)

	blocker.enabled = value
	return SUCCESS
