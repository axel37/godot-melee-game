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
@export_range(.1, 3, .1) var buffer_delay: float = .4
@export_range(0, 1.5, .1) var buffer_time: float = .3

# TODO : Allow configuring colors
# TODO : Immediately update buffer when health goes UP
# TODO : Healing buffer ?

func _ready() -> void:
	buffer_timer.timeout.connect(_on_buffer_timeout)

func _set_value(value: float) -> void:
	current_value = maxf(min_value, value)

	viz_current.size.x = _get_viz_size_for_value(current_value)

	buffer_timer.start(buffer_delay)

func _on_buffer_timeout() -> void:
	var next_value:float = _get_viz_size_for_value(current_value)
	create_tween().set_ease(Tween.EASE_IN).tween_property(viz_prev, "size:x", next_value, buffer_time)

func _get_viz_size_for_value(next_size: float) -> float:
	return viz_bg.size.x * (next_size / max_value)
