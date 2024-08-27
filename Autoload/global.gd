extends Node

@onready var _logger: Logger = %Logger

func log(code: String, message: String) -> void:
	_logger.log(code, message)
