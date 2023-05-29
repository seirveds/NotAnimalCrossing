extends StaticBody2D

var enterable = false

func _process(delta):
	if Input.is_action_just_pressed("interact") and enterable:
		print("allemachies")

func _on_interaction_area_area_entered(area):
	if area.name == "PlayerInteractionArea":
		enterable = true


func _on_interaction_area_area_exited(area):
	enterable = false
