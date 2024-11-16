extends BTAction

@export var target_position_to_check_var: StringName = &"target_position"
@export var is_in_range_var: StringName = &"target_in_range"

@export var max_distance_to_pass: float = 3

## TODO : Too naive ! This doesn't check whether the enemy is FACING the target !
func _tick(_delta: float) -> Status:
	var target_position: Vector3 = blackboard.get_var(target_position_to_check_var)
	if target_position == null:
		return FAILURE

	var distance_to_target: float = agent.global_position.distance_to(target_position)
	var is_in_range: bool = distance_to_target <= max_distance_to_pass

	blackboard.set_var(is_in_range_var, is_in_range)

	return SUCCESS
