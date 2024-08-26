## This class is used to tuck away movement code from the Player class.
@icon("res://Assets/Class icons/movement-processor.svg")
class_name MovementProcessor
extends Node

func process_movement(_character: CharacterBody3D, _delta: float, _move_max_speed: float, _move_jump_impulse: float) -> void:
	_warn_abstract_class()
	pass

func rotate_camera(_node_to_rotate: Node3D, _motion: Vector2, _sensitivity: float) -> void:
	_warn_abstract_class()
	pass


func _warn_abstract_class():
	print("MovementProcessor is considered an abstract class and should not be used directly.")
