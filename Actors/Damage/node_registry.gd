## Class to register all children of a type [br]
## Provides utility method for signal registration
class_name NodeRegistry
extends Node

var _type: String
var _registered_children: Array
var _parent: Node

func _init(type: String) -> void:
	_type = type
	_parent = get_parent()

func _ready() -> void:
	_registered_children

## Update registered children according to the type set on [member _init]
func register_children():
	for node in _parent.get_children():
		if _is_instance_of_string(node, _type):
			_registered_children.append(node)

#func connect_signal(signal_to_connect: Signal, callback: Callable):
#	for child in _registered_children:
#		_parent.connect(signal_to_connect, callback)


# Source : https://stackoverflow.com/a/77951914
# I can't believe it's not part of Godot...
# TODO : Looks expensive for being looped on many objects !
static func _is_instance_of_string(obj : Object, given_class_name : String) -> bool:
	if ClassDB.class_exists(given_class_name):
		# We have a built-in class
		return obj.is_class(given_class_name)
	else:
		# We don't have a built-in class
		# It must be a script class
		var class_script : Script
		# Assume it is a script path and try to load it
		if ResourceLoader.exists(given_class_name):
			class_script = load(given_class_name) as Script

		if class_script == null:
			# Assume it is a class name and try to find it
			for x in ProjectSettings.get_global_class_list():
				if str(x["class"]) == given_class_name:
					class_script = load(str(x["path"]))
					break

		if class_script == null:
			# Unknown class
			return false

		# Get the script of the object and try to match it
		var check_script : Script = obj.get_script()
		while check_script != null:
			if check_script == class_script:
				return true

			check_script = check_script.get_base_script()

		# Match not found
		return false
