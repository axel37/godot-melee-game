## Move agent to desired position.
## Fail if position is not reachable.
extends BTAction

const LOG_CODE_NO_TARGET: String = "TASK-MOVETOPOSITION-001"

@export var target_position_var: StringName = &"position"

@export var tolerance: float = 1

func _tick(_delta: float) -> Status:
	## Step 1 : Retrieve target position from blackboard, or fail
	var target_position: Vector3 = blackboard.get_var(target_position_var)
	if  target_position == null:
		Global.log(LOG_CODE_NO_TARGET, "Task Failure : No target position specified for agent %s" % agent.name)
		return FAILURE

	var agent_position: Vector3 = agent.global_position
	var distance_to_target: float = agent_position.distance_to(target_position)

	## TODO : Infinite loop (always RUNNING) if target is not reachable !
	## Implement failsafe mechanism if not moving for too long ?
	if distance_to_target <= tolerance:
		return SUCCESS
	else:
		## Move agent
		## TODO : Don't set target again if already set to current ?
		agent.set_movement_target(target_position)
		return RUNNING
