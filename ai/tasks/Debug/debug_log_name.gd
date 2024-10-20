## Simple Task that will log the agent's name and class
extends BTAction

const LOG_CODE_LOG_NAME: String = "TASK-LOGNAME-001"

func _tick(delta: float) -> Status:
	Global.log(LOG_CODE_LOG_NAME, "%s - %s" % [agent.name, agent.get_class()])

	return Status.SUCCESS
