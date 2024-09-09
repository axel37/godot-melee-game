@icon("res://Assets/Class icons/global.svg")
## Autoloaded general-purpose utility script.
## Specific functionality should be delegated to child nodes !
extends Node

const LOG_CODE_TIMESCALE_CHANGED = "[GLOBAL-001]"

## Internal logger node.
@onready var _logger: Logger = %Logger
## Engine time scale.
@export_range(0, 2, 0.1) var time_scale: float = 1.0:
	set = _set_time_scale

## Centralized logging. See the [_logger] child node for configuration options !
func log(code: String, message: String) -> void:
	if _logger == null:
		push_warning("Tried to log, but _logger was null ! Falling back to print instead...")
		print("<Fallback Logger> [%s] %s" % [code, message])
		return
	_logger.log(code, message)

## Setter for [member time_scale]
func _set_time_scale(value: float) -> void:
	# TODO : We might want to update "max physics ticks per frame" here
	time_scale = value
	Engine.time_scale = value
	self.log(LOG_CODE_TIMESCALE_CHANGED, "Engine time scale set to %f" % value)
