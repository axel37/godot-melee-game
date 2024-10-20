extends CharacterBody3D

@export var movement_speed: float = 2.0
@onready var navigation_agent: NavigationAgent3D = %NavigationAgent3D

var target: Node3D

func _ready() -> void:
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func _physics_process(delta):
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if target != null:
		set_movement_target(target.position)
	if navigation_agent.is_navigation_finished():
		return

	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	look_at(Vector3(next_path_position.x, global_position.y, next_path_position.z))

	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * movement_speed
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
	if body == self: return
	print("Got target %s" % body.name)
	target = body

func _on_keep_following_area_3d_body_exited(body: Node3D) -> void:
	if body == target:
		print("Lost target %s" % target.name)
		target = null
