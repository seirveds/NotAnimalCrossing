extends CharacterBody2D

@onready var animationTree = $AnimationTree
@onready var animationState = animationTree.get("parameters/playback")

func _physics_process(delta):
	move_and_slide()

func set_animationtree_blend_position(velocity: Vector2):
	animationTree.set("parameters/Idle/blend_position", velocity)
	animationTree.set("parameters/Moving/blend_position", velocity)
	
func update_animationstate(state: int):
	if state == 0:
		animationState.travel("Idle")
	else:
		animationState.travel("Moving")

func _on_interaction_component_interaction():
	# TODO add to inventory
	queue_free()

func _on_butterfly_ai_velocity_changed(newVelocity: Vector2, state: int):
	velocity = newVelocity
	set_animationtree_blend_position(velocity)
	update_animationstate(state)
