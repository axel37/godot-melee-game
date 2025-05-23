extends LimboHSM

signal health_changed(current_value: int)

@onready var roaming_state: BTState = %RoamingState
@onready var combat_state: BTState = %CombatState
@onready var stagger_state: LimboState = %StaggerState


## Amount of damage to sustain before death occurs
@export var health: int = 2

# Movement / navigation-related
@export var movement_speed: float = 2.0
@onready var navigation_agent: NavigationAgent3D = %NavigationAgent3D


# Particles spawned when taking damage
@onready var hurt_particles: GPUParticles3D = %HurtParticles

@export var stagger_chance: float = 0.4

func _ready() -> void:
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))

func _update(_delta: float) -> void:
	if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return

	if navigation_agent.is_navigation_finished():
		return

	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	agent.look_at(Vector3(next_path_position.x, agent.global_position.y, next_path_position.z))

	var new_velocity: Vector3 = agent.global_position.direction_to(next_path_position) * movement_speed * agent.movement_speed_multiplier
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func _setup() -> void:
	blackboard.bind_var_to_property(&"target", agent, &"target", true)
	_init_state_machine()

func _init_state_machine() -> void:
	add_transition(roaming_state, combat_state, &"detected_target")
	add_transition(combat_state, roaming_state, &"lost_target")
	add_transition(ANYSTATE, stagger_state, &"got_hurt")
	add_transition(stagger_state, combat_state, stagger_state.EVENT_FINISHED)


func _on_target_detector_area_3d_body_entered(body: Node3D) -> void:
	agent.target = body
	dispatch(&"detected_target")

func _on_keep_following_area_3d_body_exited(body: Node3D) -> void:
	if body == agent.target:
		agent.target = null
		dispatch(&"lost_target")


func _on_damage_receiving_handler_received_damage() -> void:
	var particles: GPUParticles3D = hurt_particles.duplicate()
	Global.level_manager.reparent_to_level(particles)
	particles.global_transform = agent.global_transform
	particles.emitting = true
	health -= 1
	health_changed.emit(health)

	if health <= 0:
		dispatch(&"died")
		return

	if randf_range(0, 1) > 1 - stagger_chance:
		dispatch(&"got_hurt")

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func _on_velocity_computed(safe_velocity: Vector3):
	agent.velocity = safe_velocity
	if not agent.is_on_floor():
		agent.velocity += agent.get_gravity()
	agent.move_and_slide()


func _on_hazard_detector_detected_damage(_damage_dealer: DamageDealer) -> void:
	if combat_state.blackboard.has_var(&"is_hazard_detected") and combat_state.blackboard.get_var(&"is_hazard_detected") == true:
		return
	combat_state.blackboard.set_var(&"is_hazard_detected", true)
