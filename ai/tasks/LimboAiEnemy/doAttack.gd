## Make LimboAiEnemy play its attack animation
extends BTAction

func _tick(_delta: float) -> Status:
	var animation_tree: AnimationTree = agent.get_node("BlenderAnimationTree")
	var playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]
	playback.travel("anim-attack-windup")
	## While attacking, return RUNNING
	## When done, return SUCCESS
	return SUCCESS
