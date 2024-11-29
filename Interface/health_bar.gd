@tool
extends Control

@onready var viz_bg: ColorRect = %Background
@onready var viz_prev: ColorRect = %ValuePrevious
@onready var viz_current: ColorRect = %Value
@onready var buffer_timer: Timer = %BufferTimer


@export var min_value: float = 0
@export var max_value: float = 100
@export_range(0, 100, .1) var current_value: float = 100:
	set = _set_value
@export_range(0, 3, .1) var buffer_time: float = .7

# TODO : Allow configuring colors

func _ready() -> void:
	buffer_timer.timeout.connect(_on_buffer_timeout)

func _set_value(value: float) -> void:
	current_value = maxf(min_value, value)

	viz_current.size.x = viz_bg.size.x * (current_value / max_value)

	buffer_timer.start(buffer_time)

func _on_buffer_timeout() -> void:
	# TODO : Duplicate code with set_value, extract ?
	viz_prev.size.x = viz_bg.size.x * (current_value / max_value)
