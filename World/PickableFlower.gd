extends StaticBody2D

@onready var interactionArea = $InteractionArea
@onready var sprite = $Sprite
@onready var animationPlayer = $AnimationPlayer

var pickable = false


func _ready():
	# Using frames we can pick a random tree sprite to show
	var frameCount = sprite.get("hframes")
	var randomFrameNumber = randi_range(0, frameCount - 1)
	sprite.set("frame", randomFrameNumber)


func _process(delta):
	pass


func _on_interaction_area_area_entered(area):
	if area.name == "PlayerInteractionArea":
		pickable = true
	if area.name == "PlayerUnderfootInteractionArea":
		animationPlayer.play("Shake")

func _on_interaction_area_area_exited(area):
	pickable = false
