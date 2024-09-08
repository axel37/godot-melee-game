@icon("res://Assets/Class icons/global.svg")
extends Node

const LOG_CODE_TIMESCALE_CHANGED = "[GLOBAL-001]"

@onready var _logger: Logger = %Logger
@export_range(0, 2, 0.1) var time_scale: float = 1.0:
	set = _set_time_scale

func log(code: String, message: String) -> void:
	if _logger == null:
		push_warning("Tried to log, but _logger was null ! Falling back to print instead...")
		print("<Fallback Logger> [%s] %s" % [code, message])
		return
	_logger.log(code, message)

func _set_time_scale(value: float) -> void:
	time_scale = value
	Engine.time_scale = value
	self.log(LOG_CODE_TIMESCALE_CHANGED, "Engine time scale set to %f" % value)
