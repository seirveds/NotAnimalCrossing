extends CharacterBody2D

@onready var animationTree = $AnimationTree
@onready var animationState = animationTree.get("parameters/playback")
@onready var searchArea = $SearchArea
@onready var timer = $Timer

enum {
	FLYING,
	IDLE,
	WANDER
}
var state = IDLE

const SPEED = 40
var angle = -PI
var catchable = false

func _ready():
	start_timer()

func _physics_process(delta):
	#print(timer.time_left)
	match state:
		FLYING:
			flying_state(delta)
		IDLE:
			idle_state(delta)
		WANDER:
			wander_state(delta)
	
func flying_state(delta):
	pass
	
func idle_state(delta):
	animationState.travel("Idle")
	# Slowly come to stop, not immediately
	velocity = velocity * 0.9
	move_and_slide()
	
func wander_state(delta):
	# Fly in small circles PLACEHOLDER
	angle += delta
	if angle > PI:
		angle = -PI
	velocity = Vector2(cos(angle), sin(angle)) * SPEED
	
	animationTree.set("parameters/Idle/blend_position", velocity)
	animationTree.set("parameters/Moving/blend_position", velocity)
	animationState.travel("Moving")
	
	move_and_slide()


func find_flower(radius: int = 5):
	var potentialTargets = searchArea.get_overlapping_areas()
	print(potentialTargets)
	# get_overlapping_areas matches all areas, we only want areas
	# that have flower as parent node
	potentialTargets = potentialTargets.filter(
		func(node):
			return node.get_parent().name.contains("Flower")
	)
	
	print(potentialTargets)

	if potentialTargets.size() == 0:
		state = WANDER
	else:
		#state = FLYING
		var targetFlower = potentialTargets.pick_random()
		# Placeholder, repace with navigation code
		self.global_position = targetFlower.global_position
		state = IDLE
	
func start_timer(time=null):
	timer.set("autostart", true)
	if not time:
		time = randi_range(1, 5)
	timer.start(time)

func _on_interaction_area_area_entered(area):
	if area.name == "PlayerInteractionArea":
		catchable = true


func _on_interaction_area_area_exited(area):
	catchable = false


func _on_timer_timeout():
	if state == WANDER:
		state = IDLE
	elif state == IDLE:
		# Find flower, goto
		find_flower()
	else:
		pass
	start_timer()
