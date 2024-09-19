@tool
## Node used to load visual "skins" (to separate visuals from logic)
class_name SkinHandler
extends Node


@export var skin_scene: PackedScene

var skin: Node3D

func get_skin() -> Node3D:
	if skin == null:
		var scene_to_load: PackedScene = skin_scene
		if scene_to_load == null:
			scene_to_load = load("res://Actors/MissingSkin.tscn")
		skin = scene_to_load.instantiate()
	return skin

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array = []
	if skin_scene == null:
		warnings.append("'skin_scene' is not defined. A placeholder will be shown.")
	return warnings
