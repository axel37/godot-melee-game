extends Node3D

@onready var animation_tree: AnimationTree = $AnimationTree

@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]

func attack():
	state_machine.travel("attack")

func guard():
	state_machine.travel("guard")
