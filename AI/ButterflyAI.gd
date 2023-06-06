extends Node2D

@onready var searchArea = $SearchArea
@onready var timer = $Timer
@onready var navigationAgent = $NavigationAgent2D

const STATETIMERLIMITS = [1, 5]

enum {
	IDLE,
	FLYING,
	WANDER,
}
var state = IDLE

var speed = 20
var angle = -PI
var catchable = false
var targetPosition = Vector2.ZERO
var velocity = Vector2.ZERO

signal velocityChanged(newVelocity: Vector2, state: int)

func _ready():
	start_timer()


func _physics_process(delta):
	match state:
		FLYING:
			flying_state(delta)
		IDLE:
			idle_state(delta)
		WANDER:
			wander_state(delta)
			
	velocityChanged.emit(velocity, state)


func flying_state(delta):
	navigationAgent.target_position = targetPosition
	velocity = (navigationAgent.get_next_path_position() - self.global_position).normalized() * speed
	
	if self.global_position.distance_to(targetPosition) < 1:
		state = IDLE


func idle_state(delta):
	# Slowly come to stop, not immediately
	velocity = velocity * 0.7


func wander_state(delta):
	# Placeholder
	# Should pick random position on edge of search area and move to
	# that position in state FLYING
	angle += delta
	if angle > PI:
		angle = -PI
	velocity = Vector2(cos(angle), sin(angle)) * speed


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
		time = randi_range(STATETIMERLIMITS[0], STATETIMERLIMITS[1])
	timer.start(time)


func _on_timer_timeout():
	if state in [WANDER, IDLE]:
		find_flower()
	start_timer()
