extends CharacterBody2D

const ACCELERATION = 700
const FRICTION = 1000

@onready var animationPlayer = $AnimationPlayer
@onready var animationTree = $AnimationTree
@onready var animationState = animationTree.get("parameters/playback")

@onready var directionMarker = $DirectionMarker

func run_key_pressed():
	return Input.is_key_pressed(KEY_SHIFT)


func get_speed():
	# Hold shift to run
	if run_key_pressed():
		return 60
	return 30


func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		directionMarker.set("rotation", input_vector.angle())
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Walk/blend_position", input_vector)
		if run_key_pressed():
			animationState.travel("Run")
		else:
			animationState.travel("Walk")
		velocity = velocity.move_toward(input_vector * get_speed(), ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	move_and_slide()
	
