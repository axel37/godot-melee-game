## Class to register all children of a type [br]
## Provides utility method for signal registration
class_name NodeRegistry
extends Node

var _type: Script
var _registered_children: Array
var _parent: Node

func _init(type: Script) -> void:
	_type = type

func _ready() -> void:
	_parent = get_parent()
	register_children()

## Update registered children according to [member _type]
func register_children():
	for node in _parent.get_children():
		if is_instance_of(node, _type):
			_registered_children.append(node)

# TODO : Signals might need to be updated when registering new children !
func connect_signal(signal_name: String, callback: Callable):
	for child in _registered_children:
		var signal_to_connect: Signal = Signal(child, signal_name)
		signal_to_connect.connect(callback)
