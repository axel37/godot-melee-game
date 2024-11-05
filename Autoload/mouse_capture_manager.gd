## Handles capturing or freeing the mouse cursor from the game's window.
extends Node

func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			# TODO : This doesn't work
			get_viewport().set_input_as_handled()
