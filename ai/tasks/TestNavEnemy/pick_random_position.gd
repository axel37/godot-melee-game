## Picks a random position on a nav mesh
## WARNING : Agent is expected to have a "NavigationAgent3D" direct child node
## TODO : Make configurable (min / max range)
extends BTAction

@export var chosen_position_var: StringName = &"position"

const LOG_CODE_POSITION_PICKED: String = "TASK-PICKRANDOMPOSITION-001"
const LOG_CODE_NO_NAV_AGENT: String = "TASK-PICKRANDOMPOSITION-002"
const LOG_CODE_POSITION_ZERO: String = "TASK-PICKRANDOMPOSITION-003"


## Pick a position
func _tick(_delta: float) -> Status:
	## Step 1 : Get NavigationAgent3D or fail
	var navigation_agent: NavigationAgent3D = agent.find_child("NavigationAgent3D")
	if navigation_agent == null:
		Global.log(LOG_CODE_NO_NAV_AGENT, "Task Failed : Could not find NavigationAgent3D for agent %s" % agent.name)
		return FAILURE

	## Step 2 : Pick a random position
	var chosen_position: Vector3 = _pick_position_for_agent(navigation_agent)

	## If position was zero, something PROBABLY went wrong
	if chosen_position == Vector3.ZERO:
		Global.log(LOG_CODE_POSITION_ZERO, "Task Failed : Picked position was Vector3.ZERO, aborting (something probably went wrong). Agent : %s" % agent.name)
		return FAILURE

	## Step 3 : Save result to blackboard
	_save_result_to_blackboard(chosen_position)

	return SUCCESS


func _pick_position_for_agent(nav_agent: NavigationAgent3D) -> Vector3:
	var navigation_map: RID = nav_agent.get_navigation_map()
	var navigation_layer: int = nav_agent.navigation_layers

	return NavigationServer3D.map_get_random_point(navigation_map, navigation_layer, false)

func _save_result_to_blackboard(chosen_position: Vector3) -> void:
	Global.log(LOG_CODE_POSITION_PICKED, "Agent %s picked random position : %s" % [agent.name, chosen_position])
	blackboard.set_var(chosen_position_var, chosen_position)
