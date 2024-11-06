## This node manages ImGui debug overlays
extends Node

var menu_is_open: bool = false

## Will attempt to retrieve values from Global autoload until true
var values_have_been_initialized = false

# Values bound to the ImGui menus. Needed since we can't bind existing values directly...
var debug_overlay_enable: Array = []
var debug_overlay_enable_damage_receiver: Array = []
var debug_overlay_enable_damage_blocker: Array = []
var debug_overlay_enable_damage_dealer: Array = []


## Open / Close the menu and release / capture the mouse
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("open_debug_menu"):
		menu_is_open = not menu_is_open
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if menu_is_open else Input.MOUSE_MODE_CAPTURED


## Display the menu !
func _process(_delta: float) -> void:
	_init_values()

	if menu_is_open:
		ImGui.Begin("Debug menu")
		ImGui.SeparatorText("Debug overlays")
		ImGui.Checkbox("Enable", debug_overlay_enable)
		ImGui.BeginDisabled(!debug_overlay_enable[0])
		ImGui.Checkbox("Damage Receivers", debug_overlay_enable_damage_receiver)
		ImGui.Checkbox("Damage Blockers", debug_overlay_enable_damage_blocker)
		ImGui.Checkbox("Damage Dealers", debug_overlay_enable_damage_dealer)
		ImGui.EndDisabled()

		ImGui.End()

		_update_variables()

# Retrieve initial values once
func _init_values():
	if values_have_been_initialized or Global.game_settings == null: return

	# Initialize values
	debug_overlay_enable = [Global.game_settings.debug_overlay_enable]
	debug_overlay_enable_damage_receiver = [Global.game_settings.debug_overlay_enable_damage_receiver]
	debug_overlay_enable_damage_blocker = [Global.game_settings.debug_overlay_enable_damage_blocker]
	debug_overlay_enable_damage_dealer = [Global.game_settings.debug_overlay_enable_damage_dealer]

	# Mark job as done, so it's only executed once
	values_have_been_initialized = true

## Manually update the variables, since we can't bind them directly...
# TODO : Find a way to do this automatically, I just forgot to add new variables to this method ! ARGH
func _update_variables():
	Global.game_settings.debug_overlay_enable = debug_overlay_enable[0]
	Global.game_settings.debug_overlay_enable_damage_blocker = debug_overlay_enable_damage_blocker[0]
	Global.game_settings.debug_overlay_enable_damage_receiver = debug_overlay_enable_damage_receiver[0]
	Global.game_settings.debug_overlay_enable_damage_dealer = debug_overlay_enable_damage_dealer[0]
