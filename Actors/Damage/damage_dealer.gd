@icon("res://Assets/Class icons/damage-dealer.svg")
## Area3D used to deal damage to [DamageReceiver]
## It's only monitorable and does no monitoring by itself.
class_name DamageDealer
extends UniqueShapeArea3D

const LOG_CODE_DAMAGE_DEALT = "DAMAGE-001"
const LOG_CODE_SET_ENABLED = "DAMAGE-005"
const LOG_CODE_RECEIVER_ALREADY_HIT = "DAMAGE-003"
const LOG_CODE_WAS_BLOCKED = "DAMAGE-006"

signal was_blocked

@export var amount: float = 0
@export var enabled: bool = true:
	set = _set_enabled

## Used to differentiate attacks for reused DamageDealers
var id: DamageId

func _ready() -> void:
	# Needed to call UniqueShapeArea3D's make unique mechanism
	super._ready()
	monitoring = false
	_renew()

## Called by external entities who blocked this attack
func block() -> void:
	was_blocked.emit()
	Global.log(LOG_CODE_WAS_BLOCKED, "%s was blocked()" % name)

# On enabled = true, _renew() and _reset_child_shapes()
func _set_enabled(value: bool):
	if enabled == value:
		return  # TODO : Avoid redundant sets (this is being called every frame !)

	enabled = value
	monitorable = value

	if value == true:
		_renew()
		_reset_child_shapes()

	Global.log(LOG_CODE_SET_ENABLED, "%s : _set_enabled %s" % [name, value])

## DamageReceivers will consider this to be a new attack, and will allow themselves to be hit again.
func _renew() -> void:
	# Prevent unused objects from hanging around
	if id != null:
		id.queue_free()
	id = DamageId.new()

func _reset_child_shapes():
	# Toggle children shapes to reset their detection from other areas
		for child in get_children():
			if child is CollisionShape3D:
				var shape: CollisionShape3D = child as CollisionShape3D
				shape.disabled = true
				shape.disabled = false

func _process(delta: float) -> void:
	for child in get_children():
		if child is CollisionShape3D:
			var shape: Shape3D = child.shape
			if shape is BoxShape3D:
				var box: BoxShape3D = shape
				var position: Vector3 = child.global_position
				var rotation: Quaternion = Quaternion(child.global_transform.basis)
				var size: Vector3 = box.size
				DebugDraw3D.draw_box(position, rotation, size, Color.FIREBRICK, true)
