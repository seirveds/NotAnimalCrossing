extends CharacterBody2D

@onready var light = $Light


func _physics_process(delta):
	# TEMP
	if Globals.hour < 5 or Globals.hour > 18:
		light.set("enabled", true)
	else:
		light.set("enabled", false)
		
	move_and_slide()


func _on_firefly_ai_velocity_changed(newVelocity):
	velocity = newVelocity


func _on_interaction_component_interaction():
	queue_free()
