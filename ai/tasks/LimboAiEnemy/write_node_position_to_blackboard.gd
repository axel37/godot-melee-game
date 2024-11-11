## Writes a Node3D's position to a variable in the blackboard.
extends BTAction

## Blackboard variable storing a Node3D. This Node3D's position will be used.
@export var source_node_var: StringName = &"target"
## Where to write out the new position (blackboard var name)
@export var position_var: StringName = &"target_position"

const LOG_CODE_NOT_NODE3D = "TASK-SETNODEPOSITIONTOBLACKBOARD-001"

func _tick(delta: float) -> Status:
	## Step 1 : Get target Node3D (or fail)
	var blackboard_var_target = blackboard.get_var(source_node_var)
	if blackboard_var_target is not Node3D or blackboard_var_target == null:
		Global.log(LOG_CODE_NOT_NODE3D, "A Node3D could not be retrieved from blackboard var %s" % source_node_var)
		return FAILURE
	var target: Node3D = blackboard_var_target

	## Step 2 : Write target Node3D's position to blackboard
	blackboard.set_var(position_var, target.global_position)
	return SUCCESS
