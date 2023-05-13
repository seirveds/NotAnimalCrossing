extends CharacterBody2D

@onready var animationTree = $AnimationTree

# Movement
const SPEED = 40

# AI
var angle = -PI

# Interaction
var catchable = false


func _physics_process(delta):
	# Placeholder AI, make butterfly fly circles
	angle += delta
	if angle > PI:
		angle = -PI
	velocity = Vector2(cos(angle), sin(angle)) * SPEED
	animationTree.set("parameters/blend_position", velocity)
	move_and_slide()



func _on_interaction_area_area_entered(area):
	if area.name == "PlayerInteractionArea":
		catchable = true


func _on_interaction_area_area_exited(area):
	catchable = false
