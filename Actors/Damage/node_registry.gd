## Class to register all children of a type
## Provides utility method for signal registration
class_name NodeRegistry
extends Node

var _type: String
var _registered_children: Array
var _parent: Node

func _init(type: String) -> void:
	_type = type
	_parent = get_parent()

func _register_children():
	for node in _parent.get_children():
		# TODO : Test this, seems bad !
		if node.is_class(_type) or node.get_script().get_global_name() == _type :
			_registered_children.append(node)

#func connect_signal(signal_to_connect: Signal, callback: Callable):
#	for child in _registered_children:
#		_parent.connect(signal_to_connect, callback)
