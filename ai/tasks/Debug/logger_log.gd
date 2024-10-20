## Task to use Global.log() standalone.
## Alternative to the built-in print() task.
extends BTAction

@export var message: String

const LOG_CODE_LOGGED: String = "TASK-LOGGER-001"
const LOG_CODE_NO_MESSAGE: String = "TASK-LOGGER-002"


func _tick(delta: float) -> Status:
	if message == null:
		Global.log(LOG_CODE_NO_MESSAGE, "Task failed : Logger was called without a message.")

	Global.log(LOG_CODE_LOGGED, "Agent %s logged : %s" % [agent.name, message])
	return SUCCESS
