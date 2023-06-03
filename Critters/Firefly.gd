extends CharacterBody2D


func _physics_process(delta):
	move_and_slide()


func _on_firefly_ai_velocity_changed(newVelocity):
	velocity = newVelocity


func _on_interaction_component_interaction():
	queue_free()
