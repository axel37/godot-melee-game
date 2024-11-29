@tool
extends Control

@onready var viz_bg: ColorRect = %Background
@onready var viz_buffer: ColorRect = %ValuePrevious
@onready var viz_current: ColorRect = %Value
@onready var buffer_timer: Timer = %BufferTimer


@export var min_value: float = 0
@export var max_value: float = 100
@export_range(0, 100, .1) var current_value: float = 100:
	set = _set_value

@export_group("Buffer", "buffer")
@export_range(.1, 3, .1) var buffer_delay: float = .4
@export_range(0, 1.5, .1) var buffer_time: float = .3

@export_group("Colors", "color")
@export var color_current: Color = Color(0.57, 0.006, 0.137):
	set(new_color):
		color_current = new_color
		viz_current.color = new_color
@export var color_buffer: Color = Color(1, 0.85, 0.845):
	set(new_color):
		color_buffer = new_color
		viz_buffer.color = new_color
@export var color_background: Color = Color(0.104, 0.104, 0.104):
	set(new_color):
		color_background = new_color
		viz_bg.color = new_color

# TODO : Update size with min and max_value
# TODO : Immediately update buffer when health goes UP
# TODO : Healing buffer ?
# TODO : Work with variables instead of each element's sizes directly (to make the code clearer)
# BUG : If value goes down then up, buffer is still at old position

func _ready() -> void:
	buffer_timer.timeout.connect(_on_buffer_timeout)

func _set_value(new_value: float) -> void:
	# Update buffer
	# If value has increase, update immediately. Else, tween it.
	if new_value > viz_buffer.size.x:
		viz_buffer.size.x = _get_viz_size_for_value(current_value)
	else:
		buffer_timer.start(buffer_delay)

	current_value = maxf(min_value, new_value)

	viz_current.size.x = _get_viz_size_for_value(current_value)


func _on_buffer_timeout() -> void:
	var next_value:float = _get_viz_size_for_value(current_value)
	create_tween().set_ease(Tween.EASE_IN).tween_property(viz_buffer, "size:x", next_value, buffer_time)

func _get_viz_size_for_value(next_size: float) -> float:
	return viz_bg.size.x * (next_size / max_value)
