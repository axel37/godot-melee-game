@icon("res://Assets/Class icons/global.svg")
extends Node

@onready var _logger: Logger = %Logger

func log(code: String, message: String) -> void:
	if _logger == null:
		push_warning("Tried to log, but _logger was null ! Falling back to print instead...")
		print("<Fallback Logger> [%s] %s" % [code, message])
		return
	_logger.log(code, message)
