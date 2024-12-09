class_name LevelManager
extends Node

## The current level
var level: Node3D

## Add a node to the level
# TODO : We may want to let the caller set the position
func reparent_to_level(node: Node) -> void:
	if level == null: _find_level()

	if node.get_parent() != null:
		node.reparent(level)
	else:
		level.add_child(node)

## The level is expected to be the last node in the scene tree
func _find_level() -> void:
	var found = get_parent().get_parent().get_child(-1)
	level = found
