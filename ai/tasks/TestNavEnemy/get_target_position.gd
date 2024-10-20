extends BTAction

const LOG_CODE_NO_TARGET: String = "TASK-GETTARGETPOSITION-001"

@export var target_position_var: StringName = &"target_position"

func _tick(delta: float) -> Status:
	if "target" not in agent or agent.target == null:
		Global.log(LOG_CODE_NO_TARGET, "Task failed : Agent %s has no target property, or its value is null." % agent.name)
		return FAILURE

	blackboard.set_var(target_position_var, agent.target.position)
	return SUCCESS
