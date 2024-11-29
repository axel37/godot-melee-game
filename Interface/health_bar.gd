## A health bar with a buffer
## The buffer represents the old value and helps visualize change over time
## Note : The health bar's size is controlled by the standard Transform / size property
## Warning : Does not work wit negative max_value
## Warning : Does not handle size changes (fixable, but it hasn't been done)
@tool
extends Control

## Will clamp current_value
@export var min_value: float = 0
## Will clamp current_value
@export var max_value: float = 100
## Represents the position of the health bar.[br]
## If current_value == max_value, the health bar is full.[br]
## If current_value == min_value, the health bar is empty.[br]
## Any value in-between and the health bar will be partially empty.
@export_range(0, 100, .1) var current_value: float = 100:
	set = _set_value

@export_group("Buffer", "buffer")
## How long to display the buffer / how long the buffer should hold the old value for.[br]
## When this delay is reached, the buffer bar adjusts to match the health bar.
@export_range(.1, 3, .1) var buffer_delay: float = .4
## Once buffer_delay has expired, how long it should take for the buffer to match the health bar.[br]
## Set this to 0 to make it instantaneous.
@export_range(0, 1.5, .1) var buffer_time: float = .3

@export_group("Colors", "color")
@export var color_health: Color = Color(0.57, 0.006, 0.137):
	set(new_color):
		color_health = new_color
		health_rect.color = new_color
@export var color_buffer: Color = Color(1, 0.85, 0.845):
	set(new_color):
		color_buffer = new_color
		buffer_rect.color = new_color
@export var color_background: Color = Color(0.104, 0.104, 0.104):
	set(new_color):
		color_background = new_color
		background_rect.color = new_color

@onready var background_rect: ColorRect = %Background
@onready var buffer_rect: ColorRect = %ValuePrevious
@onready var health_rect: ColorRect = %Value
@onready var buffer_timer: Timer = %BufferTimer

# TODO : Healing buffer ?
# BUG : If value goes down then up, buffer is still at old position
# TODO : Handle size changes
# TODO : Add border ?

func _ready() -> void:
	buffer_timer.timeout.connect(_on_buffer_timeout)

## When current_value changes, update visuals
## (setter method)
func _set_value(new_value: float) -> void:
	# Step 1 : Update buffer
	# If value has increase, update immediately. Else, tween it.
	if new_value > buffer_rect.size.x:
		buffer_rect.size.x = _get_viz_size_for_value(current_value)
	else:
		buffer_timer.start(buffer_delay)

	# Step 2 : Update internal current_value (remember, we're in a setter function !)
	current_value = clampf(new_value, min_value, max_value)

	# Step 3 : Update health bar
	health_rect.size.x = _get_viz_size_for_value(current_value)

## Buffer has reached its timeout, tween it to match current_value
func _on_buffer_timeout() -> void:
	var next_value:float = _get_viz_size_for_value(current_value)
	create_tween().set_ease(Tween.EASE_IN).tween_property(buffer_rect, "size:x", next_value, buffer_time)

## Helper function to calculate size (in pixels) of health bar
## Takes into account
func _get_viz_size_for_value(new_value: float) -> float:
	return size.x * (new_value - min_value) / (max_value - min_value)
