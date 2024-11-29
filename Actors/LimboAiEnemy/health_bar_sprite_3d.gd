extends Sprite3D

@onready var alive_state: LimboHSM = %AliveState
@onready var health_bar: HealthBar = %HealthBar

func _ready() -> void:
	health_bar.min_value = 0
	health_bar.max_value = alive_state.health
	health_bar.current_value = health_bar.max_value

func _on_alive_state_health_changed(current_value: int) -> void:
	health_bar.current_value = current_value
