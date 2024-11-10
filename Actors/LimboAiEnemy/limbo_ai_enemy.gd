extends CharacterBody3D


# AI : State machines and states
@onready var state_machine: LimboHSM = %StateMachine

@onready var alive_state: LimboHSM = %AliveState
@onready var dying_state: LimboState = %DyingState
@onready var dead_state: LimboState = %DeadState



## TODO : Next two variables may belong in alive_state...

# Used to stop moving while attacking
var movement_speed_multiplier: float = 1.0
## Enemy to attack (from this entity's point of view)
var target: Node3D


## TODO : Bouncing corpse ?


func _ready() -> void:
	_init_state_machine()

func _init_state_machine() -> void:
	state_machine.add_transition(state_machine.ANYSTATE, dying_state, &"died")
	state_machine.add_transition(dying_state, dead_state, &"finished_dying")

	# Note : 'initialize' also calls '_setup' on all children
	state_machine.initialize(self)
	state_machine.set_active(true)

func _init_alive_state_machine() -> void:
	alive_state._init_state_machine()
