## This manages game settings
class_name GameSettings
extends Node

@export_group("Damage visualizer overlays", "debug_overlay")
@export var debug_overlay_enable: bool = false
@export var debug_overlay_enable_damage_dealer: bool = true
@export var debug_overlay_enable_damage_blocker: bool = true
@export var debug_overlay_enable_damage_receiver: bool = true

@export_group("Movement vectors overlays", "debug_overlay_movement")
@export var debug_overlay_movement_enable: bool = false
@export var debug_overlay_movement_enable_wishdir: bool = true
@export var debug_overlay_movement_enable_accelerate: bool = true
