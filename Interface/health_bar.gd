@tool
extends Control

@onready var viz_bg: ColorRect = %Background
@onready var viz_prev: ColorRect = %ValuePrevious
@onready var viz_current: ColorRect = %Value

@export var min_value: float = 0
@export var max_value: float = 100
@export_range(0, 100, .1) var current_value: float = 100:
	set = _set_value

# TODO : Allow configuring delay for previous buffer thing
# TODO : Allow configuring colors

func _set_value(value: float) -> void:
	current_value = maxf(min_value, value)

	viz_current.size.x = viz_bg.size.x * (current_value / max_value)
	# TODO : Update viz sizes
