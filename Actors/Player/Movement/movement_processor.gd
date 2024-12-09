## This class is used to tuck away movement code from the Player class.
# This should be an interface D:
@icon("res://Assets/Class icons/movement-processor.svg")
class_name MovementProcessor
extends Node

func compute_next_velocity(_character: Player, _delta: float, _ignore_input: bool = false) -> Vector3:
	_warn_abstract_class()
	return Vector3.ZERO

func _warn_abstract_class():
	print("MovementProcessor is considered an abstract class and should not be used directly.")
