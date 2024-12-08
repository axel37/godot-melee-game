## Area3D used to block/guard from [DamageDealer]s
## Best used as a child of [DamageReceivingHandler]
@icon("res://Assets/Class icons/damage-blocker.svg")
class_name DamageBlocker
extends Area3D

const LOG_CODE_SET_ENABLED = "BLOCKER-001"
const LOG_CODE_DAMAGE_BLOCKED = "BLOCKER-002"

signal blocked_damage(time_since_block: float, damage_dealer: DamageDealer)

## Particles to emit when an attack has been blocked. MUST be of type GPUParticles3D
## Could be changed to allow any kind of scene (it would be up to the scene to do stuff when instanced)
@export var block_particles: PackedScene = preload("res://Actors/Damage/block_particles.tscn")
@export var block_particles_position_override: Node3D

@export var enabled: bool = true:
	set = _set_enabled

## Time this DamageBlocker has been active
var time_blocking: float = 0

## HACK : This stores the result of find_parent("*Level*") (it's a slow operation)
static var level: Node3D

func _ready() -> void:
	_renew()
	area_shape_entered.connect(_on_area_shape_entered)

func _process(delta: float) -> void:
	time_blocking += delta
	_draw_debug()

func _on_area_shape_entered(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int) -> void:
	if area is not DamageDealer: return
	var damage_dealer: DamageDealer = area
	Global.log(LOG_CODE_DAMAGE_BLOCKED, "%s blocked damage %s" % [name, damage_dealer.name])
	blocked_damage.emit(time_blocking, damage_dealer)

	_spawn_block_particles(area, area_shape_index)

func _renew() -> void:
	time_blocking = 0

func _set_enabled(value: bool):
	if enabled == value:
		return  # TODO : Avoid redundant sets (this is being called every frame !)

	enabled = value
	set_deferred("monitorable", value)
	set_deferred("monitoring", value)
	Global.log(LOG_CODE_SET_ENABLED, "%s : _set_enabled %s" % [name, value])

## Spawn VFX at the mid-point between the damage dealer and the damage blocker
## This is a good approximation for the actual collision point !
func _spawn_block_particles(area: Area3D, area_shape_index: int) -> void:
	var shape: CollisionShape3D = area.shape_owner_get_owner(area.shape_find_owner(area_shape_index))
	var shape_pos: Vector3 = shape.global_position
	var sub: Vector3 = global_position - shape_pos
	var mid: Vector3 = sub * 0.5
	var final: Vector3 = shape_pos + mid
	# Gigantic hack that works suprisngly well : spawn the particles slightly higher
	final.y += 0.75

	var particle_node: GPUParticles3D = block_particles.instantiate()
	if level == null:
		push_warning("HACK : find_parent('*Level*') - THIS WILL BREAK SHIT, I WARNED YOU")
		level = find_parent("*Level*")
	level.add_child(particle_node)
	particle_node.position = final
	particle_node.emitting = true

## Draw a wireframe box around collision shapes
func _draw_debug() -> void:
	if not Global.game_settings.debug_overlay_enable_damage_blocker : return

	var color: Color = Color.ORANGE if enabled else Color.SADDLE_BROWN
	for child in get_children():
		if child is CollisionShape3D:
			Global.debug_overlay.draw_collision_shape_3d(child, color)
