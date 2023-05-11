extends StaticBody2D

@onready var interactionArea = $InteractionArea
@onready var animationPlayer = $AnimationPlayer
@onready var sprite = $Sprite

var canBeShaken = false

func _ready():
	# Using frames we can pick a random tree sprite to show
	var frameCount = sprite.get("hframes")
	var randomFrameNumber = randi_range(1, frameCount)
	sprite.set("frame", randomFrameNumber)


func _process(delta):
	if Input.is_action_just_pressed("interact") and canBeShaken:
		animationPlayer.play("Shake")


func _on_interaction_area_area_entered(area):

	if area.name == "PlayerInteractionArea":
		canBeShaken = true


func _on_interaction_area_area_exited(area):
	canBeShaken = false
