@tool
extends CharacterBody3D

@onready var skin_handler: SkinHandler = %SkinHandler

var skin: Node3D

func _ready() -> void:
	print("Loading skin...")
	skin = skin_handler.get_skin()
	print(skin)
	add_child(skin)
