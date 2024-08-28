extends Node

@onready var _logger: Logger = %Logger

func log(code: String, message: String) -> void:
	if _logger == null:
		push_warning("Tried to log, but _logger was null !")
		return
	_logger.log(code, message)
