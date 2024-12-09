extends Node3D

@onready var block_particles: GPUParticles3D = %Sparks
@onready var circle: GPUParticles3D = %Circle

func _ready() -> void:
	block_particles.emitting = true
	circle.emitting = true
