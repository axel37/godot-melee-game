## This node manages ImGui debug overlays
extends Node

var menu_is_open: bool = false

# Values bound to the ImGui menus. Needed since we can't bind existing values directly...
var debug_time_scale: Array = []

var debug_overlay_enable: Array = []
var debug_overlay_enable_damage_receiver: Array = []
var debug_overlay_enable_damage_blocker: Array = []
var debug_overlay_enable_damage_dealer: Array = []

var debug_overlay_enable_movement: Array = []
var debug_overlay_enable_movement_wishdir: Array = []
var debug_overlay_enable_movement_accelerate: Array = []



## Open / Close the menu and release / capture the mouse
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("open_debug_menu"):
		menu_is_open = not menu_is_open
		if menu_is_open:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			_get_values_from_settings()
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


## Display the menu !
func _process(_delta: float) -> void:
	if menu_is_open:
		ImGui.Begin("Debug menu")
		ImGui.SliderFloat("Time scale", debug_time_scale, 0.1, 3)

		ImGui.SeparatorText("Damage visualizers")
		ImGui.Checkbox("Enable damage visualizers", debug_overlay_enable)
		ImGui.BeginDisabled(!debug_overlay_enable[0])
		ImGui.Checkbox("Damage Receivers", debug_overlay_enable_damage_receiver)
		ImGui.Checkbox("Damage Blockers", debug_overlay_enable_damage_blocker)
		ImGui.Checkbox("Damage Dealers", debug_overlay_enable_damage_dealer)
		ImGui.EndDisabled()

		ImGui.SeparatorText("Movement vectors")
		ImGui.Checkbox("Enable movement vectors", debug_overlay_enable_movement)
		ImGui.BeginDisabled(!debug_overlay_enable_movement[0])
		ImGui.Checkbox("Wishdir", debug_overlay_enable_movement_wishdir)
		ImGui.Checkbox("Accelerate", debug_overlay_enable_movement_accelerate)
		ImGui.EndDisabled()

		ImGui.End()

		_push_values_to_settings()

# Retrieve initial values once
func _get_values_from_settings():
	if Global.game_settings == null: return

	# Initialize values
	debug_time_scale = [Global.time_scale]

	debug_overlay_enable = [Global.game_settings.debug_overlay_enable]
	debug_overlay_enable_damage_receiver = [Global.game_settings.debug_overlay_enable_damage_receiver]
	debug_overlay_enable_damage_blocker = [Global.game_settings.debug_overlay_enable_damage_blocker]
	debug_overlay_enable_damage_dealer = [Global.game_settings.debug_overlay_enable_damage_dealer]

	debug_overlay_enable_movement = [Global.game_settings.debug_overlay_movement_enable]
	debug_overlay_enable_movement_wishdir = [Global.game_settings.debug_overlay_movement_enable_wishdir]
	debug_overlay_enable_movement_accelerate = [Global.game_settings.debug_overlay_movement_enable_accelerate]



## Manually update the variables, since we can't bind them directly...
# TODO : Find a way to do this automatically, I just forgot to add new variables to this method ! ARGH
func _push_values_to_settings():
	Global.time_scale = debug_time_scale[0]
	Global.game_settings.debug_overlay_enable = debug_overlay_enable[0]
	Global.game_settings.debug_overlay_enable_damage_blocker = debug_overlay_enable_damage_blocker[0]
	Global.game_settings.debug_overlay_enable_damage_receiver = debug_overlay_enable_damage_receiver[0]
	Global.game_settings.debug_overlay_enable_damage_dealer = debug_overlay_enable_damage_dealer[0]

	Global.game_settings.debug_overlay_movement_enable = debug_overlay_enable_movement[0]
	Global.game_settings.debug_overlay_movement_enable_accelerate = debug_overlay_enable_movement_accelerate[0]
	Global.game_settings.debug_overlay_movement_enable_wishdir = debug_overlay_enable_movement_wishdir[0]
