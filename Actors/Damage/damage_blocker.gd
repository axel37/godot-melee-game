## Area3D used to block/guard from [DamageDealer]s
## Best used as a child of [DamageReceivingHandler]
@icon("res://Assets/Class icons/damage-blocker.svg")
class_name DamageBlocker
extends Area3D

const LOG_CODE_SET_ENABLED = "BLOCKER-001"
const LOG_CODE_DAMAGE_BLOCKED = "BLOCKER-002"

signal blocked_damage(time_since_block: float, damage_dealer: DamageDealer, dealer_shape_index: int, damage_blocker: DamageBlocker, blocker_shape_indexl: int)

@export var enabled: bool = true:
	set = _set_enabled

## Time this DamageBlocker has been active
var time_blocking: float = 0

func _ready() -> void:
	_renew()
	area_shape_entered.connect(_on_area_shape_entered)

func _process(delta: float) -> void:
	time_blocking += delta
	_draw_debug()

func _on_area_shape_entered(_area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int) -> void:
	## TODO : Use local shape (local_shape_index) to increase accuracy of VFX position !
	if area is not DamageDealer: return
	var damage_dealer: DamageDealer = area
	Global.log(LOG_CODE_DAMAGE_BLOCKED, "%s blocked damage %s" % [name, damage_dealer.name])
	blocked_damage.emit(time_blocking, damage_dealer, area_shape_index, self, local_shape_index)


func _renew() -> void:
	time_blocking = 0

func _set_enabled(value: bool):
	if enabled == value:
		return  # TODO : Avoid redundant sets (this is being called every frame !)

	enabled = value
	set_deferred("monitorable", value)
	set_deferred("monitoring", value)
	Global.log(LOG_CODE_SET_ENABLED, "%s : _set_enabled %s" % [name, value])

## Draw a wireframe box around collision shapes
func _draw_debug() -> void:
	if not Global.game_settings.debug_overlay_enable_damage_blocker : return

	var color: Color = Color.ORANGE if enabled else Color.SADDLE_BROWN
	for child in get_children():
		if child is CollisionShape3D:
			Global.debug_overlay.draw_collision_shape_3d(child, color)
