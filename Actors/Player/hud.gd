extends Control

## TODO : Player's max health is manually set
@onready var health_bar: HealthBar = %HealthBar

func _on_player_health_changed(new_value: float) -> void:
	health_bar.current_value = new_value
