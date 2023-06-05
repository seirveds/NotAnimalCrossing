extends CharacterBody2D

@onready var animationTree = $AnimationTree
@onready var animationState = animationTree.get("parameters/playback")
@onready var sprite = $Sprite2D

var texture : String

func _init(newTexture: String = "Common_Butterfly.png"):
	texture = "%s%s" % [Settings.BUGTEXTUREPATH, newTexture]

func _ready():
	sprite.set("texture", load(texture))

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
	Utils.catchBug(self)

func _on_butterfly_ai_velocity_changed(newVelocity: Vector2, state: int):
	velocity = newVelocity
	set_animationtree_blend_position(velocity)
	update_animationstate(state)
