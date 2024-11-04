extends CharacterBody3D

@export var movement_speed: float = 2.0
@onready var navigation_agent: NavigationAgent3D = %NavigationAgent3D

@onready var limbo_hsm: LimboHSM = %LimboHSM
@onready var roaming_state: BTState = %RoamingState
@onready var combat_state: BTState = %CombatState
@onready var stagger_state: LimboState = %StaggerState


## TODO : Health management and death
## Death should probably be a state (in which everything is disabled and nothing else happens)

## TODO : Enemy gets hurt once even if the player isn't attacking

## TODO : Bouncing corpse ?

# Used to stop moving while attacking
var movement_speed_multiplier: float = 1.0

var target: Node3D

func _ready() -> void:
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	_init_state_machine()

func _init_state_machine() -> void:
	#limbo_hsm.add_transition(roaming_state, combat_state, roaming_state.EVENT_FINISHED)
	limbo_hsm.add_transition(roaming_state, combat_state, &"detected_target")
	#limbo_hsm.add_transition(combat_state, roaming_state, combat_state.EVENT_FINISHED)
	limbo_hsm.add_transition(combat_state, roaming_state, &"lost_target")
	limbo_hsm.add_transition(limbo_hsm.ANYSTATE, stagger_state, &"got_hurt")
	limbo_hsm.add_transition(stagger_state, combat_state, stagger_state.EVENT_FINISHED)



	limbo_hsm.initialize(self)
	limbo_hsm.set_active(true)


func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func _physics_process(_delta: float):
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if navigation_agent.is_navigation_finished():
		return

	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	look_at(Vector3(next_path_position.x, global_position.y, next_path_position.z))

	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * movement_speed * movement_speed_multiplier
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	if not is_on_floor():
		velocity += get_gravity()
	move_and_slide()


func _on_target_detector_area_3d_body_entered(body: Node3D) -> void:
	target = body
	limbo_hsm.dispatch(&"detected_target")

func _on_keep_following_area_3d_body_exited(body: Node3D) -> void:
	if body == target:
		target = null
		limbo_hsm.dispatch(&"lost_target")


func _on_damage_receiving_handler_received_damage() -> void:
	print("detected hurt")
	limbo_hsm.dispatch(&"got_hurt")
