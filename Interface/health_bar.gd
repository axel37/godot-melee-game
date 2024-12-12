## A health bar with a buffer
## The buffer represents the old value and helps visualize change over time
## Note : The health bar's size is controlled by the standard Transform / size property
## Warning : Does not work wit negative max_value
@tool
class_name HealthBar
extends Control

## Will clamp current_value
@export var min_value: float = 0:
	set = _set_min
## Will clamp current_value
@export var max_value: float = 100:
	set = _set_max
## Represents the position of the health bar.[br]
## If current_value == max_value, the health bar is full.[br]
## If current_value == min_value, the health bar is empty.[br]
## Any value in-between and the health bar will be partially empty.
@export_range(0, 100, .1) var current_value: float = 100:
	set = _set_value

@export_group("Buffer", "buffer")
## How long to display the buffer / how long the buffer should hold the old value for.[br]
## When this delay is reached, the buffer bar adjusts to match the health bar.
@export_range(.1, 3, .1, "or_greater") var buffer_delay: float = .4
## Once buffer_delay has expired, how long it should take for the buffer to match the health bar.[br]
## Set this to 0 to make it instantaneous.
@export_range(0, 1.5, .1, "or_greater") var buffer_time: float = .3

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

## Buffer proxy
## This exists so we don't have to directly work with buffer_rect
var _buffer_value: float:
	set = _set_buffer_value

var initialized: bool = false

var buffer_tween: Tween

# TODO : Healing buffer ?
# BUG : If value goes down then up, buffer is still at old position
# TODO : Add border ?

func _ready() -> void:
	buffer_timer.timeout.connect(_on_buffer_timeout)
	initialized = true
	_buffer_value = current_value
	resized.connect(_on_resized)

## When current_value changes, update visuals
## (setter method)
# TODO : Timer / tween shouldn't be fired when called by _ready
func _set_value(new_value: float) -> void:
	# Step 1 : Update current_value (remember, we're in a setter function !)
	current_value = clampf(new_value, min_value, max_value)

	# Next steps involve changing children, which may not have been initialized yet.
	# This check prevents a crash (_set_value is called before the node is ready for some reason)
	if not initialized: return

	# Step 2 : Update health bar
	health_rect.size.x = _get_rect_size_for_value(current_value)

	# Step 3 : Update buffer
	# If value has increase, update immediately. Else, tween it.
	if new_value > _buffer_value:
		_buffer_value = new_value
	else:
		buffer_timer.start(buffer_delay)



## Buffer has reached its timeout, tween it to match current_value
func _on_buffer_timeout() -> void:
	# Attempt to stop existing tween. I'm not sure it's working, but it seems OK in-game.
	if buffer_tween != null:
		buffer_tween.stop()
		buffer_tween.kill()

	buffer_tween = create_tween().set_ease(Tween.EASE_IN)
	buffer_tween.tween_property(self, "_buffer_value", current_value, buffer_time)

## Helper function to calculate size (in pixels) of health bar
## Takes into account
func _get_rect_size_for_value(new_value: float) -> float:
	return size.x * (new_value - min_value) / (max_value - min_value)

func _set_buffer_value(new_buffer_value: float) -> void:
	buffer_rect.size.x = _get_rect_size_for_value(new_buffer_value)
	_buffer_value = new_buffer_value

func _set_min(new_value: float) -> void:
	min_value = new_value
	if current_value < new_value:
		current_value = new_value

func _set_max(new_value: float) -> void:
	max_value = new_value
	if current_value > new_value:
		current_value = new_value

## On size changes, recompute proper sizes for children
func _on_resized() -> void:
	health_rect.size.x = _get_rect_size_for_value(current_value)
	health_rect.size.y = size.y
	buffer_rect.size.x = _get_rect_size_for_value(_buffer_value)
	buffer_rect.size.y = size.y
