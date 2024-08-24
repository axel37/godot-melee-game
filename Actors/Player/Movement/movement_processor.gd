## This class is used to tuck away movement code from the Player class.
class_name MovementProcessor
extends Node

func process_movement(_character: CharacterBody3D, _delta: float, _move_max_speed: float, _move_jump_impulse: float) -> void:
	print("MovementProcessor is considered an abstract class and should not be used directly.")
	pass
