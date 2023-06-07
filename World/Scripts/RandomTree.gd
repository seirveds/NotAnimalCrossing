extends StaticBody2D

@onready var animationPlayer = $AnimationPlayer
@onready var sprite = $Sprite


func _ready():
	# Using frames we can pick a random tree sprite to show
	var frameCount = sprite.get("hframes")
	var randomFrameNumber = randi_range(0, frameCount - 1)
	sprite.set("frame", randomFrameNumber)


func _process(delta):
	pass


func _on_interaction_component_interaction():
	animationPlayer.play("Shake")
