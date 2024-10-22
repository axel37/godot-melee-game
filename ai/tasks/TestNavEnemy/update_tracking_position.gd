## Tell agent to move to desired position.
## Immediately succeeds, without waiting for target to be reached.
## Fail if position is not reachable.
extends BTAction

const LOG_CODE_NO_TARGET: String = "TASK-UPDATETRACKINGPOSITION-001"

@export var target_position_var: StringName = &"position"

@export var tolerance: float = 1

func _tick(_delta: float) -> Status:
	## Step 1 : Retrieve target position from blackboard, or fail
	## get_var can return null, but we're not allowed to put null in Vector3
	var target_position_or_null = blackboard.get_var(target_position_var)
	if  target_position_or_null == null:
		Global.log(LOG_CODE_NO_TARGET, "Task Failure : No target position specified for agent %s" % agent.name)
		return FAILURE
	var target_position: Vector3 = target_position_or_null as Vector3

	var agent_position: Vector3 = agent.global_position
	var distance_to_target: float = agent_position.distance_to(target_position)



	agent.set_movement_target(target_position)
	return SUCCESS
