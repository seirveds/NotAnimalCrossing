extends CharacterBody2D

@onready var animationTree = $AnimationTree
@onready var animationState = animationTree.get("parameters/playback")
@onready var searchArea = $SearchArea
@onready var timer = $Timer
@onready var navigationAgent = $NavigationAgent2D

enum {
	FLYING,
	IDLE,
	WANDER
}
var state = IDLE

const SPEED = 20
var angle = -PI
var catchable = false
var targetPosition = Vector2.ZERO

func _ready():
	start_timer()
	
func _process(delta):
	if Input.is_action_just_pressed("interact") and catchable:
		# Placeholder,should add to player inventory
		queue_free()

func _physics_process(delta):
	match state:
		FLYING:
			flying_state(delta)
		IDLE:
			idle_state(delta)
		WANDER:
			wander_state(delta)
	
func flying_state(delta):
	navigationAgent.target_position = targetPosition
	velocity = (navigationAgent.get_next_path_position() - self.global_position).normalized() * SPEED
	set_animationtree_blend_position(velocity)
	animationState.travel("Moving")
	
	move_and_slide()
	if self.global_position.distance_to(targetPosition) < 1:
		state = IDLE
	
func idle_state(delta):
	animationState.travel("Idle")
	# Slowly come to stop, not immediately
	velocity = velocity * 0.7
	move_and_slide()
	
func wander_state(delta):
	# Placeholder
	# Should pick random position on edge of search area and move to
	# that position in state FLYING
	angle += delta
	if angle > PI:
		angle = -PI
	velocity = Vector2(cos(angle), sin(angle)) * SPEED
	
	set_animationtree_blend_position(velocity)
	animationState.travel("Moving")
	
	move_and_slide()


func find_flower(radius: int = 5):
	var potentialTargets = searchArea.get_overlapping_areas()
	# get_overlapping_areas matches all areas, we only want areas
	# that have flower as parent node
	potentialTargets = potentialTargets.filter(
		func(node):
			return node.get_parent().name.contains("Flower")
	)

	if potentialTargets.size() == 0:
		state = WANDER
	else:
		var targetFlower = potentialTargets.pick_random()
		# Placeholder, repace with navigation code	
		targetPosition = targetFlower.global_position
		state = FLYING
	
func start_timer(time=null):
	timer.set("autostart", true)
	if not time:
		time = randi_range(1, 5)
	timer.start(time)

func set_animationtree_blend_position(velocity: Vector2):
	animationTree.set("parameters/Idle/blend_position", velocity)
	animationTree.set("parameters/Moving/blend_position", velocity)


func _on_interaction_area_area_entered(area):
	if area.name == "PlayerInteractionArea":
		catchable = true


func _on_interaction_area_area_exited(area):
	catchable = false


func _on_timer_timeout():
	if state in [WANDER, IDLE]:
		find_flower()
	else:
		pass
	start_timer()
