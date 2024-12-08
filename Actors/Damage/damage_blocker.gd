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

func _ready() -> void:
	_renew()
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	time_blocking += delta
	_draw_debug()

func _on_area_entered(area: Area3D) -> void:
	if area is DamageDealer:
		var damage_dealer: DamageDealer = area as DamageDealer
		Global.log(LOG_CODE_DAMAGE_BLOCKED, "%s blocked damage %s" % [name, damage_dealer.name])
		blocked_damage.emit(time_blocking, damage_dealer)
		# Spawn particles (kinda sucks)
		# TODO : Particles are spawned at current position, which may not reflect where the attack actually landed
		# TODO : Duplicated particle spawning code ?
		# TODO : Use area_shape_entered signal to find the shape's location instead ?
		var particle_node: GPUParticles3D = block_particles.instantiate()
		get_parent().add_child(particle_node)
		var particles_position = block_particles_position_override.position if block_particles_position_override != null else position
		particle_node.position = particles_position
		particle_node.emitting = true

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
