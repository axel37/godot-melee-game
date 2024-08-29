## Centralized handling of printing stuff
@icon("res://Assets/Class icons/logger.svg")
class_name Logger
extends Node

## If true, will print to the console without requiring verbose logging.
@export var print_in_stdout: bool = false

func log(code: String, message: String) -> void:
	if print_in_stdout:
		print_rich("[color=gray][code][%s][/code] %s" % [code, message])
	else:
		print_verbose("[%s] %s" % [code, message])
